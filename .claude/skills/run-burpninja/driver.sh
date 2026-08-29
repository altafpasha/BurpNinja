#!/usr/bin/env bash
# ============================================================
#  BurpNinja skill driver
#  Agent-facing harness for launching and driving BurpNinja.
#
#  BurpNinja itself is an interactive TUI menu (BurpNinja.sh /
#  BurpNinja.ps1). This driver gives an agent a *programmatic*
#  handle on it, plus a non-destructive environment doctor that
#  mirrors BurpNinja's own detection logic.
#
#  Subcommands:
#    doctor            Non-destructive environment report (default).
#                      OS, arch, every tool + version, adb device
#                      state, root, frida client/server, Burp proxy.
#    check             Syntax-check BurpNinja.sh / bypass.js.
#    menu <keys...>    Feed menu selections to BurpNinja.sh over
#                      stdin (headless) and print ANSI-stripped
#                      output. e.g.  driver.sh menu 3 0
#    tui               Launch BurpNinja.sh live inside tmux (session
#                      'burpninja') for keystroke-level interaction.
#    capture           Print the current tmux 'burpninja' pane.
#    send <keys>       Send keys to the tmux 'burpninja' pane.
#    kill              Kill the tmux 'burpninja' session.
#
#  Paths resolve relative to the repo root (two levels up from
#  this file), so it works no matter where you run it from.
# ============================================================
set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"
SH_SCRIPT="$REPO_ROOT/BurpNinja.sh"
PS_SCRIPT="$REPO_ROOT/BurpNinja.ps1"
BYPASS_JS="$REPO_ROOT/bypass.js"
BURP_IP="${BURP_IP:-127.0.0.1:8080}"
TMUX_SESSION="burpninja"

# Literal ESC so this works with BSD sed (macOS) and GNU sed alike.
ESC=$(printf '\033')
strip_ansi() { LC_ALL=C sed "s/${ESC}\[[0-9;]*[a-zA-Z]//g; s/${ESC}[]][0-9;]*//g"; }
have()       { command -v "$1" >/dev/null 2>&1; }
line()       { printf -- '─%.0s' $(seq 1 60); echo; }
kv()         { printf "  %-16s %s\n" "$1" "$2"; }

# --- one tool: name, then version probe (best-effort) ---------
probe() {
  local name="$1"; shift
  if have "$name"; then
    local v; v="$("$@" 2>/dev/null | head -1 | tr -d '\r')"
    kv "$name" "OK  ${v:-(found: $(command -v "$name"))}"
  else
    kv "$name" "MISSING"
  fi
}

doctor() {
  line; echo "  BurpNinja environment doctor (read-only)"; line

  echo "  [ Host ]"
  kv "OS"   "$(uname -s)"
  kv "Arch" "$(uname -m)"
  if [ "$(uname -s)" = "Darwin" ]; then kv "macOS" "$(sw_vers -productVersion 2>/dev/null)"; fi
  echo

  echo "  [ PC tools ]"
  probe adb        adb --version
  probe frida      frida --version
  probe objection  objection version
  probe jadx       jadx --version
  probe apktool    apktool --version
  probe scrcpy     scrcpy --version
  probe openssl    openssl version
  probe python3    python3 --version
  probe pip3       pip3 --version
  probe xz         xz --version
  probe curl       curl --version
  probe unzip      unzip -v
  probe git        git --version
  have brew && kv "brew" "OK  $(brew --version 2>/dev/null | head -1)"
  echo

  echo "  [ BurpNinja repo ]"
  [ -f "$SH_SCRIPT" ]  && kv "BurpNinja.sh"  "present" || kv "BurpNinja.sh"  "MISSING"
  [ -f "$PS_SCRIPT" ]  && kv "BurpNinja.ps1" "present" || kv "BurpNinja.ps1" "MISSING"
  [ -f "$BYPASS_JS" ]  && kv "bypass.js"     "present" || kv "bypass.js"     "MISSING"
  if [ -f "$SH_SCRIPT" ]; then
    kv "declared VERSION" "$(grep -m1 '^VERSION=' "$SH_SCRIPT" | cut -d'"' -f2)"
  fi
  echo

  echo "  [ Android device ]"
  if have adb; then
    local state; state="$(adb get-state 2>&1 | tr -d '\r')"
    kv "adb state" "$state"
    if [ "$state" = "device" ]; then
      kv "model"   "$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
      kv "android" "$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')"
      kv "api"     "$(adb shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')"
      kv "cpu abi" "$(adb shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r')"
      local uid; uid="$(adb shell id 2>/dev/null | tr -d '\r')"
      if echo "$uid" | grep -q uid=0; then
        kv "root" "adb runs as root (uid=0)"
      elif adb shell "su 0 id" 2>/dev/null | grep -q uid=0 || adb shell "su -c id" 2>/dev/null | grep -q uid=0; then
        kv "root" "su available"
      else
        kv "root" "NOT rooted (Burp system-cert + frida-server need root)"
      fi
      # frida-server on device
      local fs=""
      for loc in /data/local/tmp/frida-server /system/xbin/frida-server; do
        if adb shell "test -f $loc" >/dev/null 2>&1; then
          fs="$(adb shell "$loc --version" 2>/dev/null | tr -d '\r')"
          kv "frida-server" "$loc ($fs)"; break
        fi
      done
      [ -z "$fs" ] && kv "frida-server" "not on device (menu [4])"
      if have frida && [ -n "$fs" ]; then
        local pc; pc="$(frida --version 2>/dev/null | tr -d '\r')"
        [ "$pc" = "$fs" ] && kv "frida match" "in sync ($pc)" \
                          || kv "frida match" "MISMATCH pc=$pc device=$fs (menu [5])"
      fi
    fi
  else
    kv "adb" "MISSING — install platform-tools"
  fi
  echo

  echo "  [ Burp proxy ($BURP_IP) ]"
  if have curl && curl -s --max-time 4 "http://$BURP_IP/" 2>/dev/null | grep -qi "burp\|proxy"; then
    kv "reachable" "yes"
  else
    kv "reachable" "no (start Burp; listener on $BURP_IP)"
  fi
  line
}

check() {
  line; echo "  Static checks"; line
  if have bash; then
    bash -n "$SH_SCRIPT" && kv "BurpNinja.sh" "bash -n OK" || kv "BurpNinja.sh" "SYNTAX ERROR"
  fi
  if have node; then
    node --check "$BYPASS_JS" && kv "bypass.js" "node --check OK" || kv "bypass.js" "PARSE ERROR"
  else
    kv "bypass.js" "node not present — skipped"
  fi
  line
}

menu() {
  # Feed each argument as a menu selection. After every action BurpNinja
  # pauses on "Press Enter to return to menu", so inject a blank line
  # after each key, then a final 0 to leave the loop cleanly.
  local keys=("$@") input=""
  for k in "${keys[@]}"; do input+="$k"$'\n\n'; done
  input+='0'$'\n'
  # Force TERM=xterm: BurpNinja calls `clear` under `set -e`, which aborts
  # at the banner if TERM is empty or "dumb" (common in headless shells).
  printf '%s' "$input" | TERM=xterm bash "$SH_SCRIPT" 2>&1 | strip_ansi
}

tui() {
  have tmux || { echo "tmux not installed"; return 1; }
  tmux kill-session -t "$TMUX_SESSION" 2>/dev/null
  tmux new-session -d -s "$TMUX_SESSION" -x 100 -y 40
  tmux send-keys -t "$TMUX_SESSION" "cd $REPO_ROOT && bash BurpNinja.sh" Enter
  sleep 3
  echo "Launched live in tmux session '$TMUX_SESSION'."
  echo "  driver.sh capture      # snapshot the screen"
  echo "  driver.sh send 3       # press 3 + Enter"
  echo "  driver.sh kill         # end session"
  capture
}

capture() {
  have tmux || { echo "tmux not installed"; return 1; }
  tmux capture-pane -t "$TMUX_SESSION" -p | strip_ansi
}

send() {
  have tmux || { echo "tmux not installed"; return 1; }
  tmux send-keys -t "$TMUX_SESSION" "$*" Enter
  sleep 3
  capture
}

kill_session() { tmux kill-session -t "$TMUX_SESSION" 2>/dev/null && echo "killed" || echo "no session"; }

cmd="${1:-doctor}"; shift || true
case "$cmd" in
  doctor)  doctor ;;
  check)   check ;;
  menu)    menu "$@" ;;
  tui)     tui ;;
  capture) capture ;;
  send)    send "$@" ;;
  kill)    kill_session ;;
  *) echo "usage: driver.sh {doctor|check|menu <keys...>|tui|capture|send <keys>|kill}"; exit 2 ;;
esac
