#!/usr/bin/env bash
# ============================================================
#  ██████╗ ██╗   ██╗██████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗     ██╗ █████╗
#  ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║     ██║██╔══██╗
#  ██████╔╝██║   ██║██████╔╝██████╔╝██╔██╗ ██║██║██╔██╗ ██║     ██║███████║
#  ██╔══██╗██║   ██║██╔══██╗██╔═══╝ ██║╚██╗██║██║██║╚██╗██║██   ██║██╔══██║
#  ██████╔╝╚██████╔╝██║  ██║██║     ██║ ╚████║██║██║ ╚████║╚█████╔╝██║  ██║
#  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═╝
# ============================================================
# ============================================================
#  Android Pentesting Setup Toolkit  |  Linux & macOS Edition
#  Author  : @altafpasha
#  Version : 2.1.0
# ============================================================

set -euo pipefail

# Resolve the script's own directory NOW, before any `cd`, so relative
# invocation (bash BurpNinja.sh) still finds repo files (e.g. bypass.js).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────
#  ENVIRONMENT & PATH SETUP (macOS & Linux)
# ─────────────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$HOME/Library/Android/sdk/platform-tools:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/cmdline-tools/latest/bin:${SUDO_USER:+/Users/$SUDO_USER/Library/Android/sdk/platform-tools}:${SUDO_USER:+/Users/$SUDO_USER/Library/Android/sdk/emulator}:$HOME/.local/bin:$PATH"

# ─────────────────────────────────────────
#  COLORS & SYMBOLS
# ─────────────────────────────────────────
C_CYAN='\033[0;36m'
C_DCYAN='\033[0;34m'
C_GREEN='\033[0;32m'
C_DGREEN='\033[2;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_MAGENTA='\033[0;35m'
C_WHITE='\033[0;37m'
C_GRAY='\033[2;37m'
C_RESET='\033[0m'
C_BOLD='\033[1m'

OK="[+]"
ERR="[!]"
WARN="[~]"
INFO="[*]"

# ─────────────────────────────────────────
#  GLOBALS
# ─────────────────────────────────────────
BURP_IP="127.0.0.1:8080"
BURP_AVAILABLE=true
BASE_DIR="/tmp/burpninja_workspace"
LOG_FILE="/tmp/burpninja_log.txt"
AI_ENABLED=false
ANTHROPIC_KEY=""
VERSION="2.2.0"

# CLI flags (set by argument parser in main()). Defaults preserve the
# original interactive behavior when the script is run with no arguments.
DRY_RUN=false
SAFE_MODE=false
VERBOSE=false
DEBUG=false

mkdir -p "$BASE_DIR"
echo "BurpNinja v$VERSION started at $(date)" > "$LOG_FILE"
cd "$BASE_DIR"

# ─────────────────────────────────────────
#  LOGGING
# ─────────────────────────────────────────
log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" >> "$LOG_FILE"
}

# ─────────────────────────────────────────
#  OUTPUT HELPERS
# ─────────────────────────────────────────
ok()   { echo -e "${C_GREEN}${OK} $1${C_RESET}";    log "$1" "SUCCESS"; }
err()  { echo -e "${C_RED}${ERR} $1${C_RESET}";    log "$1" "ERROR"; }
warn() { echo -e "${C_YELLOW}${WARN} $1${C_RESET}"; log "$1" "WARN"; }
info() { echo -e "${C_CYAN}${INFO} $1${C_RESET}";   log "$1" "INFO"; }

section() {
    local title="$1"
    local line
    line=$(printf '─%.0s' $(seq 1 $((50 - ${#title}))))
    echo ""
    echo -e "${C_DCYAN}  ┌─ ${title} ${C_GRAY}${line}${C_RESET}"
}

# ─────────────────────────────────────────
#  ROOT / PRIVILEGE CHECK
# ─────────────────────────────────────────
check_root() {
    if [[ $EUID -ne 0 ]]; then
        if [[ "$(uname -s)" == "Darwin" ]]; then
            info "Running on macOS (${USER:-Apple}). Standard permissions."
        else
            err "Run as root: sudo bash BurpNinja.sh"
            exit 1
        fi
    fi
}

# ─────────────────────────────────────────
#  BANNER
# ─────────────────────────────────────────
show_banner() {
    clear
    echo ""
    echo -e "${C_CYAN}  ██████╗ ██╗   ██╗██████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗     ██╗ █████╗ ${C_RESET}"
    echo -e "${C_CYAN}  ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║     ██║██╔══██╗${C_RESET}"
    echo -e "${C_DCYAN}  ██████╔╝██║   ██║██████╔╝██████╔╝██╔██╗ ██║██║██╔██╗ ██║     ██║███████║${C_RESET}"
    echo -e "${C_DCYAN}  ██╔══██╗██║   ██║██╔══██╗██╔═══╝ ██║╚██╗██║██║██║╚██╗██║██   ██║██╔══██║${C_RESET}"
    echo -e "${C_DCYAN}  ██████╔╝╚██████╔╝██║  ██║██║     ██║ ╚████║██║██║ ╚████║╚█████╔╝██║  ██║${C_RESET}"
    echo -e "${C_GRAY}  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═╝${C_RESET}"
    echo ""
    echo -e "${C_GRAY}  ─────────────────────────────────────────────────────────────────────────${C_RESET}"
    if $AI_ENABLED; then
        echo -e "   ${C_WHITE}Android Pentesting Setup Toolkit${C_RESET}  ${C_GRAY}│  Linux & macOS  │  v${VERSION}${C_RESET}  ${C_MAGENTA}│  AI: ON ✦${C_RESET}"
    else
        echo -e "   ${C_WHITE}Android Pentesting Setup Toolkit${C_RESET}  ${C_GRAY}│  Linux & macOS  │  v${VERSION}  │  AI: OFF${C_RESET}"
    fi
    echo -e "   ${C_GRAY}Author: @altafpasha${C_RESET}"
    echo -e "${C_GRAY}  ─────────────────────────────────────────────────────────────────────────${C_RESET}"
    echo ""
}

# ─────────────────────────────────────────
#  DEPENDENCY & PACKAGE MANAGERS
# ─────────────────────────────────────────
require() {
    command -v "$1" &>/dev/null || { err "$1 not found. Install it first."; exit 1; }
}

get_brew_cmd() {
    if command -v brew &>/dev/null; then
        command -v brew
    elif [[ -x "/opt/homebrew/bin/brew" ]]; then
        echo "/opt/homebrew/bin/brew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        echo "/usr/local/bin/brew"
    elif [[ -n "${SUDO_USER:-}" ]] && sudo -u "$SUDO_USER" command -v brew &>/dev/null; then
        sudo -u "$SUDO_USER" which brew
    else
        echo ""
    fi
}

install_pkg() {
    local pkg="$1"
    local brew_bin
    brew_bin=$(get_brew_cmd)

    if [[ -n "$brew_bin" ]]; then
        info "Installing $pkg via Homebrew..."
        if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" ]]; then
            sudo -u "$SUDO_USER" "$brew_bin" install "$pkg" && ok "Installed $pkg" || err "Failed to install $pkg via brew"
        else
            "$brew_bin" install "$pkg" && ok "Installed $pkg" || err "Failed to install $pkg via brew"
        fi
    elif command -v apt-get &>/dev/null; then
        apt-get install -y "$pkg" &>/dev/null && ok "Installed $pkg" || err "Failed to install $pkg"
    elif command -v pacman &>/dev/null; then
        pacman -S --noconfirm "$pkg" &>/dev/null && ok "Installed $pkg" || err "Failed to install $pkg"
    elif command -v dnf &>/dev/null; then
        dnf install -y "$pkg" &>/dev/null && ok "Installed $pkg" || err "Failed to install $pkg"
    else
        warn "Cannot auto-install $pkg. Install manually."
    fi
}

# ─────────────────────────────────────────
#  AI ERROR HANDLER
# ─────────────────────────────────────────
ai_analyze() {
    local context="$1"
    local command="$2"
    local output="$3"

    # Return 0 when AI is disabled: callers invoke this as a bare statement
    # under `set -e`, so a non-zero return here would abort the whole script
    # (this was silently killing the Burp/ADB/cert recovery prompts).
    $AI_ENABLED || return 0

    section "AI Error Analysis"
    info "Sending error context to Claude AI..."

    local prompt
    prompt="You are an expert Android pentesting assistant specializing in Burp Suite, Frida, and ADB running on Linux.
A tool called BurpNinja encountered this error during setup. Give a concise diagnosis and fix.

CONTEXT: ${context}
COMMAND: ${command}
OUTPUT: ${output}

Respond in this exact format:
DIAGNOSIS: <one line>
FIX: <exact command or step to fix>
PREVENTION: <one line tip>"

    local payload
    payload=$(printf '{"model":"claude-sonnet-4-20250514","max_tokens":400,"messages":[{"role":"user","content":"%s"}]}' \
        "$(echo "$prompt" | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')")

    local response
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: ${ANTHROPIC_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "$payload" \
        --max-time 15 2>/dev/null || true)

    local ai_text
    ai_text=$(echo "$response" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d['content'][0]['text'])
except:
    print('')
" 2>/dev/null || true)

    if [[ -n "$ai_text" ]]; then
        echo ""
        while IFS= read -r line; do
            if [[ "$line" =~ ^DIAGNOSIS: ]]; then
                echo -e "  ${C_YELLOW}${line}${C_RESET}"
            elif [[ "$line" =~ ^FIX: ]]; then
                echo -e "  ${C_GREEN}${line}${C_RESET}"
            elif [[ "$line" =~ ^PREVENTION: ]]; then
                echo -e "  ${C_CYAN}${line}${C_RESET}"
            fi
        done <<< "$ai_text"
        echo ""
        log "AI: $ai_text" "AI"
    else
        warn "AI response empty or failed"
    fi
}

ai_log_review() {
    if ! $AI_ENABLED; then
        warn "AI mode is disabled. Enable it from the menu first."
        return
    fi
    [[ -f "$LOG_FILE" ]] || { warn "No log file found."; return; }

    section "AI Full Session Review"
    info "Sending session log to Claude AI..."

    local logs
    logs=$(tail -c 4000 "$LOG_FILE")

    local prompt
    prompt="You are a senior Android pentesting engineer reviewing a BurpNinja setup session log on Linux.
Summarize what was done, what failed, and give a prioritized action list to fix issues.

LOG:
${logs}

Format:
SUMMARY: <2 lines>
ERRORS FOUND: <list or None>
ACTION PLAN:
1. ...
2. ..."

    local payload
    payload=$(python3 -c "
import json, sys
p = sys.stdin.read()
print(json.dumps({'model':'claude-sonnet-4-20250514','max_tokens':600,'messages':[{'role':'user','content':p}]}))
" <<< "$prompt" 2>/dev/null)

    local response
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: ${ANTHROPIC_KEY}" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "$payload" \
        --max-time 20 2>/dev/null || true)

    python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d['content'][0]['text'])
except:
    print('AI response failed.')
" <<< "$response" 2>/dev/null || true
    echo ""
}

# ─────────────────────────────────────────
#  ENABLE AI
# ─────────────────────────────────────────
enable_ai() {
    section "Enable AI Mode"
    echo -e "  ${C_GRAY}AI mode uses Claude (Anthropic) API to analyze errors and suggest fixes.${C_RESET}"
    echo -e "  ${C_DCYAN}Get your key at: https://console.anthropic.com${C_RESET}"
    echo ""
    read -rp "  Enter Anthropic API Key (sk-ant-...): " key
    key="${key// /}"

    if [[ "$key" =~ ^sk-ant- ]]; then
        local test_resp
        test_resp=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
            -H "x-api-key: $key" \
            -H "anthropic-version: 2023-06-01" \
            -H "content-type: application/json" \
            -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"ping"}]}' \
            --max-time 10 2>/dev/null || true)

        if echo "$test_resp" | grep -q '"content"'; then
            ANTHROPIC_KEY="$key"
            AI_ENABLED=true
            ok "AI Mode enabled. Claude is watching your back."
        else
            err "API key validation failed. Check key and connection."
        fi
    else
        err "Invalid key format. Should start with sk-ant-"
    fi
}

# ─────────────────────────────────────────
#  CONNECTIVITY CHECKS
# ─────────────────────────────────────────
test_internet() {
    section "Internet Connectivity"
    if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        ok "Internet connection OK"
    else
        err "No internet connection"
        ai_analyze "Internet connectivity check failed" "ping 8.8.8.8" "Timeout"
        exit 1
    fi
}

# Best-effort attempt to launch a locally installed Burp Suite.
# Returns 0 if a launch was actually attempted, 1 if none was found.
launch_burp() {
    case "$(uname -s)" in
        Darwin)
            local app
            for app in "Burp Suite Community Edition" "Burp Suite Professional" "Burp Suite"; do
                if open -a "$app" 2>/dev/null; then
                    info "Launching '$app' — give it a few seconds to start."
                    return 0
                fi
            done
            ;;
        Linux)
            local bin
            for bin in burpsuite BurpSuiteCommunity BurpSuitePro; do
                if command -v "$bin" &>/dev/null; then
                    nohup "$bin" >/dev/null 2>&1 &
                    info "Launching '$bin' — give it a few seconds to start."
                    return 0
                fi
            done
            ;;
    esac
    warn "Couldn't find a Burp Suite installation to launch automatically."
    return 1
}

test_burpsuite() {
    section "Burp Suite Proxy"
    local try_connect
    try_connect() {
        curl -s --max-time 5 "http://$1/" 2>/dev/null | grep -q "Burp\|200\|proxy" && return 0 || return 1
    }

    if try_connect "$BURP_IP"; then
        BURP_AVAILABLE=true
        ok "Burp Suite running at $BURP_IP"
        return 0
    fi

    err "Burp Suite not detected at $BURP_IP"
    ai_analyze "Burp proxy unreachable" "curl http://${BURP_IP}/" "Connection refused"
    echo ""
    echo -e "  ${C_WHITE}Burp Suite isn't reachable at ${BURP_IP}.${C_RESET}"
    echo -e "  ${C_GRAY}Start Burp Suite, then in Proxy > Proxy settings make sure a listener${C_RESET}"
    echo -e "  ${C_GRAY}is on ${BURP_IP} (bind to 'All interfaces' for a physical device).${C_RESET}"

    BURP_AVAILABLE=false

    # Dry-run or no interactive terminal: don't block — report and move on.
    if $DRY_RUN; then
        warn "Dry-run: skipping Burp start prompt."
        return 0
    fi
    if [[ ! -t 0 ]]; then
        warn "No interactive terminal — start Burp and re-run. Continuing without it."
        return 0
    fi

    local choice custom_ip i
    while true; do
        echo ""
        echo -e "  ${C_WHITE}[1]${C_RESET} Retry — I've started Burp"
        echo -e "  ${C_WHITE}[2]${C_RESET} Enter a different proxy address"
        echo -e "  ${C_WHITE}[3]${C_RESET} Try to launch Burp Suite for me"
        echo -e "  ${C_WHITE}[4]${C_RESET} Skip Burp for now (cert step will be skipped)"
        echo -e "  ${C_WHITE}[0]${C_RESET} Cancel"
        read -rp "  Select: " choice || choice=""
        case "$choice" in
            1)
                if try_connect "$BURP_IP"; then
                    BURP_AVAILABLE=true; ok "Burp Suite running at $BURP_IP"; return 0
                else err "Still not reachable at $BURP_IP."; fi
                ;;
            2)
                read -rp "  Enter Burp proxy (e.g. 192.168.1.10:8080): " custom_ip || custom_ip=""
                custom_ip="${custom_ip// /}"
                if [[ -n "$custom_ip" ]] && try_connect "$custom_ip"; then
                    BURP_IP="$custom_ip"; BURP_AVAILABLE=true
                    ok "Burp Suite running at $BURP_IP"; return 0
                else err "Cannot reach Burp at ${custom_ip:-<empty>}."; fi
                ;;
            3)
                if launch_burp; then
                    info "Waiting for Burp to come up (up to ~20s)..."
                    for i in 1 2 3 4 5 6 7 8 9 10; do
                        sleep 2
                        if try_connect "$BURP_IP"; then
                            BURP_AVAILABLE=true; ok "Burp Suite running at $BURP_IP"; return 0
                        fi
                    done
                    warn "Burp still not reachable at $BURP_IP. Once it's up, choose [1] Retry."
                fi
                ;;
            4)
                warn "Skipping Burp. The certificate step will be skipped; other steps continue."
                BURP_AVAILABLE=false
                return 0
                ;;
            0|"")
                info "Cancelled. Start Burp Suite, then run BurpNinja again."
                exit 0
                ;;
            *)
                err "Invalid option"
                ;;
        esac
    done
}

adb_root_exec() {
    local cmd="$1"
    local whoami
    whoami=$(adb shell id 2>/dev/null || true)
    if echo "$whoami" | grep -q "uid=0"; then
        adb shell "$cmd"
    elif adb shell "su 0 id" 2>/dev/null | grep -q "uid=0"; then
        adb shell "su 0 sh -c \"$cmd\""
    else
        adb shell "su -c \"$cmd\""
    fi
}

test_adb() {
    section "ADB Connection"
    require adb

    local state
    state=$(adb get-state 2>&1 || true)
    if [[ "$state" == "device" ]]; then
        ok "ADB connected"
    else
        err "ADB device not ready: $state"
        ai_analyze "ADB device not connected" "adb get-state" "$state"
        exit 1
    fi

    section "Root Access"
    local whoami
    whoami=$(adb shell id 2>/dev/null || true)
    if echo "$whoami" | grep -q "uid=0"; then
        ok "Running as root (uid=0)"
        return
    fi

    local root_test
    root_test=$(adb_root_exec "echo __root_ok__" 2>/dev/null || true)
    if echo "$root_test" | grep -q "__root_ok__"; then
        ok "Root access OK (su available)"
    else
        warn "Root access not available"
        echo -e "  ${C_DCYAN}AVD     : https://github.com/newbit1/rootAVD${C_RESET}"
        echo -e "  ${C_DCYAN}Genymotion: https://t.ly/n_5F${C_RESET}"
        ai_analyze "Root access denied" "su -c 'echo test'" "Permission denied"
        exit 1
    fi
}

# ─────────────────────────────────────────
#  CERTIFICATE MANAGEMENT
# ─────────────────────────────────────────
install_cert() {
    section "Burp Certificate"
    # Skip cleanly if Burp was unavailable/skipped (needs the proxy to fetch the cert).
    if ! ${BURP_AVAILABLE:-true}; then
        warn "Burp not available — skipping certificate install."
        return
    fi
    # Auto-install OpenSSL if missing
    if ! command -v openssl &>/dev/null; then
        warn "OpenSSL not found. Attempting auto-install..."
        install_pkg openssl

        # Re-check after install attempt
        if ! command -v openssl &>/dev/null; then
            err "OpenSSL could not be installed automatically."
            err "Install manually: apt install openssl  OR  pacman -S openssl  OR  dnf install openssl  OR  brew install openssl"
            ai_analyze "OpenSSL missing" "command -v openssl" "not found"
            return
        fi
        ok "OpenSSL installed successfully"
    fi

    local cert_exists
    cert_exists=$(adb_root_exec "ls /system/etc/security/cacerts/" 2>/dev/null | grep "9a5ba575.0" || true)

    local proceed="y"
    if [[ -n "$cert_exists" ]]; then
        warn "Existing Burp cert found (9a5ba575.0)"
        read -rp "  Replace it? [Y/N]: " proceed
    fi

    [[ "$proceed" =~ ^[Yy]$ ]] || { info "Certificate unchanged"; return; }

    info "Downloading certificate from Burp..."
    if ! curl -s --max-time 10 "http://${BURP_IP}/cert" -o cacert.der; then
        err "Failed to download certificate from ${BURP_IP}"
        ai_analyze "Burp cert download failed" "curl http://${BURP_IP}/cert" "curl error"
        return
    fi

    info "Converting DER → PEM..."
    openssl x509 -inform DER -in cacert.der -out cacert.pem 2>/dev/null
    local hash
    hash=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem 2>/dev/null | head -1)
    local cert_name="${hash}.0"
    cp cacert.pem "$cert_name"

    info "Pushing $cert_name to device..."
    adb push "$cert_name" /sdcard/ >/dev/null 2>&1

    info "Remounting /system as rw..."
    adb remount >/dev/null 2>&1 || true
    adb_root_exec "mount -o rw,remount /system" >/dev/null 2>&1 || true

    adb_root_exec "mv /sdcard/${cert_name} /system/etc/security/cacerts/" >/dev/null 2>&1
    adb_root_exec "chmod 644 /system/etc/security/cacerts/${cert_name}" >/dev/null 2>&1
    adb_root_exec "chown root:root /system/etc/security/cacerts/${cert_name}" >/dev/null 2>&1

    ok "Certificate installed. Run: adb reboot"
    log "Cert installed: $cert_name" "INFO"
}

# ─────────────────────────────────────────
#  ANDROID APPS
# ─────────────────────────────────────────
install_android_apps() {
    section "Android Apps"

    install_apk() {
        local pkg="$1" name="$2" url="$3" apk="$4" grant="${5:-}"
        local installed
        installed=$(adb shell "pm list packages" 2>/dev/null | grep "$pkg" || true)

        if [[ -n "$installed" ]]; then
            echo -e "  ${C_DGREEN}${OK} $name already installed${C_RESET}"
            return
        fi

        info "Downloading $name..."
        if curl -sL "$url" -o "$apk" --max-time 60; then
            local result
            result=$(adb install -t -r "$apk" 2>&1 || true)
            if echo "$result" | grep -q "Success"; then
                [[ -n "$grant" ]] && adb shell "pm grant $grant" >/dev/null 2>&1 || true
                ok "$name installed"
            else
                err "Install failed for $name: $result"
                ai_analyze "APK install failed" "adb install $apk" "$result"
            fi
        else
            err "Download failed for $name"
        fi
    }

    # ProxyToggle (distributed inside zip release)
    local pt_installed
    pt_installed=$(adb shell "pm list packages" 2>/dev/null | grep "com.kinandcarta.create.proxytoggle" || true)
    if [[ -n "$pt_installed" ]]; then
        echo -e "  ${C_DGREEN}${OK} ProxyToggle already installed${C_RESET}"
    else
        info "Downloading ProxyToggle..."
        if curl -sL "https://github.com/theappbusiness/android-proxy-toggle/releases/download/v1.0.1/Proxy.Toggle.v1.0.1.zip" -o "proxytoggle.zip" --max-time 60; then
            unzip -o proxytoggle.zip -d . >/dev/null 2>&1 || true
            local pt_apk=""
            [[ -f "proxy-toggle.apk" ]] && pt_apk="proxy-toggle.apk"
            [[ -f "Proxy.Toggle.v1.0.1.apk" ]] && pt_apk="Proxy.Toggle.v1.0.1.apk"
            [[ -z "$pt_apk" ]] && pt_apk=$(find . -maxdepth 2 -name "*.apk" | grep -i "proxy.*toggle" | head -1 || true)

            if [[ -n "$pt_apk" && -f "$pt_apk" ]]; then
                local result
                result=$(adb install -t -r "$pt_apk" 2>&1 || true)
                if echo "$result" | grep -q "Success"; then
                    adb shell "pm grant com.kinandcarta.create.proxytoggle android.permission.WRITE_SECURE_SETTINGS" >/dev/null 2>&1 || true
                    ok "ProxyToggle installed"
                else
                    err "Install failed for ProxyToggle: $result"
                    ai_analyze "APK install failed" "adb install $pt_apk" "$result"
                fi
            else
                err "Failed to extract ProxyToggle APK from zip"
            fi
        else
            err "Download failed for ProxyToggle"
        fi
    fi

    install_apk \
        "com.sujanpoudel.adbwifi" "ADB WiFi" \
        "https://github.com/raoshaab/Andro_set/raw/main/assets/adb_wifi.apk" \
        "wifiadb.apk"

    install_apk \
        "org.proxydroid" "ProxyDroid" \
        "https://github.com/raoshaab/Andro_set/raw/main/assets/org.proxydroid.apk" \
        "proxydroid.apk"

    install_apk \
        "org.fdroid.fdroid" "F-Droid" \
        "https://f-droid.org/F-Droid.apk" \
        "fdroid.apk"

    install_apk \
        "com.aurora.store" "Aurora Store" \
        "https://f-droid.org/repo/com.aurora.store_65.apk" \
        "aurora.apk"
}

# ─────────────────────────────────────────
#  PC TOOLS
# ─────────────────────────────────────────
install_pc_tools() {
    section "PC Tools (JADX / Apktool / Scrcpy / Frida / Objection)"

    # jadx
    if ! command -v jadx &>/dev/null; then
        info "Installing jadx..."
        local brew_bin
        brew_bin=$(get_brew_cmd)
        if [[ -n "$brew_bin" ]]; then
            install_pkg jadx
        else
            local ver
            ver=$(curl -sI "https://github.com/skylot/jadx/releases/latest" | grep -i location | sed 's/.*\/v//' | tr -d '\r\n')
            curl -sL "https://github.com/skylot/jadx/releases/download/v${ver}/jadx-${ver}.zip" -o jadx.zip --max-time 120
            mkdir -p /opt/jadx 2>/dev/null || mkdir -p "$HOME/.local/jadx"
            local jadx_dir="/opt/jadx"
            [[ ! -w "/opt" && -d "$HOME/.local/jadx" ]] && jadx_dir="$HOME/.local/jadx"
            unzip -o jadx.zip -d "$jadx_dir" >/dev/null 2>&1 || true
            mkdir -p /usr/local/bin 2>/dev/null || mkdir -p "$HOME/.local/bin"
            ln -sf "$jadx_dir/bin/jadx" /usr/local/bin/jadx 2>/dev/null || ln -sf "$jadx_dir/bin/jadx" "$HOME/.local/bin/jadx" 2>/dev/null || true
            ln -sf "$jadx_dir/bin/jadx-gui" /usr/local/bin/jadx-gui 2>/dev/null || ln -sf "$jadx_dir/bin/jadx-gui" "$HOME/.local/bin/jadx-gui" 2>/dev/null || true
            ok "jadx installed"
        fi
    else
        echo -e "  ${C_DGREEN}${OK} jadx already installed${C_RESET}"
    fi

    # apktool
    if ! command -v apktool &>/dev/null; then
        info "Installing apktool..."
        install_pkg apktool
    else
        echo -e "  ${C_DGREEN}${OK} apktool already installed${C_RESET}"
    fi

    # scrcpy
    if ! command -v scrcpy &>/dev/null; then
        info "Installing scrcpy..."
        install_pkg scrcpy
    else
        echo -e "  ${C_DGREEN}${OK} scrcpy already installed${C_RESET}"
    fi

    # frida + objection
    if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
        err "pip not found. Install python3-pip"
        return
    fi

    local PIP
    PIP=$(command -v pip3 || command -v pip)

    local frida_ok objection_ok
    frida_ok=$($PIP list 2>/dev/null | grep -i frida || true)
    objection_ok=$($PIP list 2>/dev/null | grep -i objection || true)

    if [[ -n "$frida_ok" && -n "$objection_ok" ]]; then
        echo -e "  ${C_DGREEN}${OK} Frida and Objection already installed${C_RESET}"
    else
        info "Installing Frida + Objection..."
        local result
        result=$($PIP install frida frida-tools objection --break-system-packages 2>&1 || $PIP install frida frida-tools objection 2>&1 || true)
        if echo "$result" | grep -q "Successfully installed\|already satisfied"; then
            ok "Frida + Objection installed"
        else
            err "pip install failed"
            ai_analyze "pip install frida objection failed" "pip install frida frida-tools objection" "$result"
        fi
    fi
}

# ─────────────────────────────────────────
#  FRIDA SERVER
# ─────────────────────────────────────────
get_latest_github_release() {
    local repo="$1"
    local loc
    loc=$(curl -sI "https://github.com/${repo}/releases/latest" 2>/dev/null | grep -i "^location:" | head -1 | tr -d '\r\n')
    if [[ -n "$loc" ]]; then
        echo "$loc" | sed -E 's/.*\/tag\/v?//' | sed -E 's/.*\/v//' | tr -d ' '
    else
        echo ""
    fi
}

install_magisk_module() {
    local ver
    ver=$(get_latest_github_release "ViRb3/magisk-frida")
    info "Downloading MagiskFrida v${ver}..."
    curl -sL "https://github.com/ViRb3/magisk-frida/releases/download/v${ver}/MagiskFrida-${ver}.zip" \
        -o frida_module.zip --max-time 120
    adb push frida_module.zip /data/local/tmp/ >/dev/null 2>&1
    adb_root_exec "magisk --install-module /data/local/tmp/frida_module.zip" >/dev/null 2>&1
    ok "MagiskFrida module installed"

    info "Downloading TrustUserCerts module..."
    curl -sL "https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip" \
        -o trust_module.zip --max-time 60
    adb push trust_module.zip /data/local/tmp/ >/dev/null 2>&1
    adb_root_exec "magisk --install-module /data/local/tmp/trust_module.zip" >/dev/null 2>&1
    ok "TrustUserCerts module installed"
}

install_frida_manual() {
    local cpu
    cpu=$(adb shell "getprop ro.product.cpu.abi" 2>/dev/null | tr -d '\r\n')
    local arch
    case "$cpu" in
        x86_64*) arch="x86_64" ;;
        x86*)    arch="x86" ;;
        arm64*)  arch="arm64" ;;
        arm*)    arch="arm" ;;
        *)       err "Unknown CPU arch: $cpu"; return ;;
    esac

    # Ensure xz decompressor is installed
    if ! command -v xz &>/dev/null; then
        info "Installing xz..."
        install_pkg xz
    fi

    local ver
    ver=$(get_latest_github_release "frida/frida")
    [[ -z "$ver" ]] && ver="17.17.0"
    info "Frida v${ver} for ${arch} detected"

    local url="https://github.com/frida/frida/releases/download/${ver}/frida-server-${ver}-android-${arch}.xz"
    rm -f frida-server frida-server.xz "frida-server-${ver}-android-${arch}"
    info "Downloading Frida server from GitHub..."
    curl -sL "$url" -o frida-server.xz --max-time 300

    if [[ -f frida-server.xz ]]; then
        xz -df frida-server.xz 2>/dev/null || true
    fi

    local binary="frida-server"
    if [[ ! -f "$binary" && -f "frida-server-${ver}-android-${arch}" ]]; then
        mv "frida-server-${ver}-android-${arch}" "$binary"
    fi

    if [[ -f "$binary" ]]; then
        adb push "$binary" /data/local/tmp/frida-server >/dev/null 2>&1
        adb_root_exec "chmod 755 /data/local/tmp/frida-server" >/dev/null 2>&1
        adb_root_exec "mount -o rw,remount /system" >/dev/null 2>&1 || true
        adb_root_exec "cp /data/local/tmp/frida-server /system/xbin/frida-server" >/dev/null 2>&1 || true
        ok "Frida server installed at /data/local/tmp/frida-server"
        echo -e "  ${C_DCYAN}Start: adb shell \"/data/local/tmp/frida-server &\"${C_RESET}"
    else
        err "Failed to extract frida-server binary"
    fi
}

install_frida_android() {
    section "Frida Server (Android)"
    local existing=""
    if adb shell "test -f /data/local/tmp/frida-server" &>/dev/null; then
        existing=$(adb shell "/data/local/tmp/frida-server --version" 2>/dev/null | tr -d '\r\n' || true)
    elif adb shell "test -f /system/xbin/frida-server" &>/dev/null; then
        existing=$(adb shell "/system/xbin/frida-server --version" 2>/dev/null | tr -d '\r\n' || true)
    fi

    if [[ -n "$existing" ]]; then
        warn "Frida already installed on Android: $existing"
        read -rp "  Upgrade/reinstall? [Y/N]: " choice
        [[ "$choice" =~ ^[Yy]$ ]] || return
    fi

    local magisk
    magisk=$(adb shell "magisk -v" 2>/dev/null || true)
    if echo "$magisk" | grep -qi "MAGISK"; then
        install_magisk_module
    else
        install_frida_manual
    fi
}

repair_frida_version() {
    section "Frida Version Sync"
    local latest pc_ver adb_ver
    latest=$(get_latest_github_release "frida/frida")
    pc_ver=$(frida --version 2>/dev/null | tr -d '\n' || echo "not installed")

    if adb shell "test -f /data/local/tmp/frida-server" &>/dev/null; then
        adb_ver=$(adb shell "/data/local/tmp/frida-server --version" 2>/dev/null | tr -d '\r\n' || echo "not installed")
    elif adb shell "test -f /system/xbin/frida-server" &>/dev/null; then
        adb_ver=$(adb shell "/system/xbin/frida-server --version" 2>/dev/null | tr -d '\r\n' || echo "not installed")
    else
        adb_ver=$(adb shell "frida-server --version" 2>/dev/null | tr -d '\r\n' || echo "not installed")
    fi
    [[ -z "$adb_ver" ]] && adb_ver="not installed"

    echo -e "  Latest   : ${C_WHITE}${latest}${C_RESET}"
    [[ "$pc_ver"  == "$latest" ]] && echo -e "  PC       : ${C_GREEN}${pc_ver}${C_RESET}"  || echo -e "  PC       : ${C_YELLOW}${pc_ver}${C_RESET}"
    [[ "$adb_ver" == "$latest" ]] && echo -e "  Android  : ${C_GREEN}${adb_ver}${C_RESET}" || echo -e "  Android  : ${C_YELLOW}${adb_ver}${C_RESET}"
    echo ""

    if [[ "$pc_ver" == "$adb_ver" && "$pc_ver" != "not installed" ]]; then
        ok "Versions in sync ($pc_ver)"
        return
    fi

    local PIP
    PIP=$(command -v pip3 || command -v pip)
    [[ "$pc_ver" != "$latest" ]] && { info "Upgrading PC frida..."; $PIP install frida frida-tools --upgrade --break-system-packages -q 2>/dev/null || $PIP install frida frida-tools --upgrade -q; }
    [[ "$adb_ver" != "$latest" ]] && install_frida_manual
    ok "Frida sync complete"
}

# ─────────────────────────────────────────
#  DEVICE INFO
# ─────────────────────────────────────────
show_device_info() {
    section "Device Information"
    local props=(
        "Model:ro.product.model"
        "Brand:ro.product.brand"
        "Android:ro.build.version.release"
        "API:ro.build.version.sdk"
        "CPU ABI:ro.product.cpu.abi"
    )
    for p in "${props[@]}"; do
        local label="${p%%:*}"
        local prop="${p##*:}"
        local val
        val=$(adb shell "getprop $prop" 2>/dev/null | tr -d '\r\n')
        printf "  %-12s: %s\n" "$label" "$val"
    done
    local serial
    serial=$(adb get-serialno 2>/dev/null | tr -d '\r\n')
    printf "  %-12s: %s\n" "Serial" "$serial"
    echo ""
}

# ─────────────────────────────────────────
#  INSTALL ALL
# ─────────────────────────────────────────
install_all() {
    test_internet
    test_burpsuite
    test_adb
    install_pc_tools
    install_android_apps
    install_frida_android
    install_cert
    echo ""
    ok "All done. Run: adb reboot"
}

# ─────────────────────────────────────────
#  FRIDA SSL BYPASS
# ─────────────────────────────────────────
ssl_bypass() {
    section "Frida SSL Bypass"

    # ── Ask for package name ──────────────────────────
    read -rp "  Enter target package (e.g. com.target.app): " package
    package="${package// /}"
    if [[ -z "$package" ]]; then
        err "Package name cannot be empty"
        return
    fi

    # ── Locate bypass.js ────────────────────────────
    # Use SCRIPT_DIR captured at startup (before any cd) so the repo's
    # maintained bypass.js is found reliably, not the inline fallback.
    local bypass_src="$SCRIPT_DIR/bypass.js"
    local bypass_dst="$BASE_DIR/bypass.js"

    if [[ "$bypass_src" != "$bypass_dst" && -f "$bypass_src" ]]; then
        cp "$bypass_src" "$bypass_dst"
        info "Using bypass.js from repo: $bypass_src"
    elif [[ -f "$bypass_dst" ]]; then
        info "Using bypass.js at: $bypass_dst"
    else
        # Inline fallback
        cat > "$bypass_dst" << 'BYPASS_EOF'
Java.perform(function () {
    console.log("[+] BurpNinja SSL Bypass Active");

    // Force Proxy Routing to Burp Suite (10.0.2.2:8080)
    try {
        var System = Java.use('java.lang.System');
        System.setProperty('http.proxyHost', '10.0.2.2');
        System.setProperty('http.proxyPort', '8080');
        System.setProperty('https.proxyHost', '10.0.2.2');
        System.setProperty('https.proxyPort', '8080');
    } catch (e) {}

    try {
        var Proxy = Java.use('java.net.Proxy');
        var InetSocketAddress = Java.use('java.net.InetSocketAddress');
        var ProxyType = Java.use('java.net.Proxy$Type');
        var burpProxy = Proxy.$new(ProxyType.HTTP.value, InetSocketAddress.$new('10.0.2.2', 8080));

        var OkHttpClientBuilder = Java.use('okhttp3.OkHttpClient$Builder');
        OkHttpClientBuilder.build.implementation = function () {
            this.proxy(burpProxy);
            return this.build();
        };
    } catch (e) {}

    // TrustManager bypass
    var X509TrustManager = Java.use("javax.net.ssl.X509TrustManager");
    var SSLContext = Java.use("javax.net.ssl.SSLContext");
    var TrustManager = Java.registerClass({
        name: "dev.asd.test.TrustManager",
        implements: [X509TrustManager],
        methods: {
            checkClientTrusted: function () {},
            checkServerTrusted: function () {},
            getAcceptedIssuers: function () { return []; }
        }
    });
    var SSLContext_init = SSLContext.init.overload(
        "[Ljavax.net.ssl.KeyManager;",
        "[Ljavax.net.ssl.TrustManager;",
        "java.security.SecureRandom"
    );
    SSLContext_init.implementation = function (km, tm, sr) {
        console.log("[+] SSL Pinning Bypassed!");
        SSLContext_init.call(this, km, [TrustManager.$new()], sr);
    };

    // OkHttp3 CertificatePinner bypass
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function () {};
        CertificatePinner.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;').implementation = function () {};
    } catch (e) {}

    // NetworkSecurityConfig bypass
    try {
        var NetworkSecurityConfig = Java.use('android.security.net.config.RootTrustManager');
        NetworkSecurityConfig.checkServerTrusted.implementation = function () {};
    } catch (e) {}
});
BYPASS_EOF
        info "bypass.js written to: $bypass_dst"
    fi

    # ── Forward Frida ports ─────────────────────────
    info "Forwarding Frida ports (27042, 27043)..."
    adb forward tcp:27042 tcp:27042 &>/dev/null || true
    adb forward tcp:27043 tcp:27043 &>/dev/null || true

    # ── Find frida-server on device ─────────────────────
    local frida_bin=""
    for loc in /system/xbin/frida-server /data/local/tmp/frida-server; do
        if adb shell "test -f $loc" &>/dev/null; then
            frida_bin="$loc"
            break
        fi
    done

    if [[ -z "$frida_bin" ]]; then
        warn "frida-server not found on device."
        warn "Run option [4] to install Frida first, then retry."
        ai_analyze "frida-server missing" "adb shell test -f /system/xbin/frida-server" "not found"
        return
    fi
    ok "Found frida-server at: $frida_bin"

    # ── Kill old instance ──────────────────────────────
    info "Stopping any existing frida-server..."
    adb shell "pkill -9 frida-server" &>/dev/null || true
    sleep 1

    # ── Start frida-server as non-blocking daemon ───────
    info "Starting frida-server daemon..."
    adb_root_exec "nohup $frida_bin >/dev/null 2>&1 &"
    sleep 2

    # Check if running, fallback to -D
    if ! adb shell "pidof frida-server" &>/dev/null; then
        adb_root_exec "$frida_bin -D" &>/dev/null || true
        sleep 1
    fi
    ok "frida-server active on device"

    # ── Check PC frida ──────────────────────────────────
    if ! command -v frida &>/dev/null; then
        err "frida not found on PC. Run option [3] to install Frida tools first."
        return
    fi

    # ── Inject ─────────────────────────────────────────
    ok "Injecting SSL bypass into: $package"
    echo ""
    echo -e "  ${C_DCYAN}CMD: frida -U -f $package -l $bypass_dst${C_RESET}"
    echo ""
    frida -U -f "$package" -l "$bypass_dst"
}

# ─────────────────────────────────────────
#  MAIN MENU
# ─────────────────────────────────────────
main_menu() {
    while true; do
        show_banner

        echo -e "  ${C_GRAY}SETUP${C_RESET}"
        echo -e "  ${C_WHITE}[1] Full Install (All)${C_RESET}"
        echo -e "  ${C_WHITE}[2] Move Burp Certificate → Android System${C_RESET}"
        echo -e "  ${C_WHITE}[3] PC Tools  (JADX · Apktool · Scrcpy · Frida)${C_RESET}"
        echo -e "  ${C_WHITE}[4] Android Frida Server${C_RESET}"
        echo -e "  ${C_WHITE}[5] Fix Frida Version Mismatch${C_RESET}"
        echo -e "  ${C_WHITE}[6] Android Apps  (ProxyToggle · ProxyDroid · ADBWifi · F-Droid · Aurora)${C_RESET}"
        echo ""
        echo -e "  ${C_GRAY}DEVICE${C_RESET}"
        echo -e "  ${C_WHITE}[7] Device Info${C_RESET}"
        echo ""
        echo -e "  ${C_GRAY}PENTEST${C_RESET}"
        echo -e "  ${C_YELLOW}[8] Frida SSL Bypass  (auto-start + inject)${C_RESET}"
        echo ""
        echo -e "  ${C_GRAY}AI${C_RESET}"
        if $AI_ENABLED; then
            echo -e "  ${C_MAGENTA}[9]  AI Session Review  (analyze full log)${C_RESET}"
            echo -e "  ${C_GRAY}[10] Disable AI Mode${C_RESET}"
        else
            echo -e "  ${C_GRAY}[9] Enable AI Mode  (Claude API)${C_RESET}"
        fi
        echo ""
        echo -e "  ${C_GRAY}[0] Exit${C_RESET}"
        echo ""
        read -rp "  Select: " opt

        case "$opt" in
            1) install_all ;;
            2) test_internet; test_adb; test_burpsuite; install_cert ;;
            3) test_internet; install_pc_tools ;;
            4) test_internet; test_adb; install_frida_android ;;
            5) test_internet; test_adb; repair_frida_version ;;
            6) test_internet; test_adb; install_android_apps ;;
            7) test_adb; show_device_info ;;
            8) test_adb; ssl_bypass ;;
            9)
                if $AI_ENABLED; then
                    ai_log_review
                else
                    enable_ai
                fi
                ;;
            10)
                AI_ENABLED=false
                ANTHROPIC_KEY=""
                info "AI Mode disabled"
                ;;
            0) echo ""; exit 0 ;;
            *) err "Invalid option" ;;
        esac

        echo ""
        read -rp "  Press Enter to return to menu..."
    done
}

# ═════════════════════════════════════════════════════════════
#  CLI LAYER  (added in v2.2.0 — 100% backward compatible)
#  Running with no arguments still launches the interactive menu.
#  New non-interactive subcommands: doctor · status · setup ·
#  help · version, plus global flags --dry-run/--safe/--verbose.
# ═════════════════════════════════════════════════════════════

# Dry-run helper: print an action instead of performing it.
would() { echo -e "  ${C_GRAY}[dry-run] would ${1}${C_RESET}"; }

# ── Doctor status printers + counters ────────────────────────
D_PASS=0; D_WARN=0; D_FAIL=0; D_NONE=0
d_pass() { D_PASS=$((D_PASS+1)); echo -e "  ${C_GREEN}[✓] PASS${C_RESET}  $1"; }
d_warn() { D_WARN=$((D_WARN+1)); echo -e "  ${C_YELLOW}[!] WARN${C_RESET}  $1"; }
d_fail() { D_FAIL=$((D_FAIL+1)); echo -e "  ${C_RED}[✗] FAIL${C_RESET}  $1"; }
d_none() { D_NONE=$((D_NONE+1)); echo -e "  ${C_GRAY}[○] N/A ${C_RESET}  $1"; }
d_fix()  {
    echo -e "          ${C_GRAY}Problem: $1${C_RESET}"
    echo -e "          ${C_GRAY}Cause:   $2${C_RESET}"
    echo -e "          ${C_GREEN}Fix:     $3${C_RESET}"
}

# Report a tool: severity(req|opt), name, then a version command.
d_tool() {
    local sev="$1" name="$2"; shift 2
    if command -v "$name" &>/dev/null; then
        local v; v="$("$@" 2>/dev/null | head -1 | tr -d '\r')"
        d_pass "$(printf '%-10s %s' "$name" "${v:-installed}")"
    elif [[ "$sev" == req ]]; then
        d_fail "$(printf '%-10s not found' "$name")"
        d_fix "$name is required and not installed" \
              "Missing from PATH or not installed" \
              "See references/installation.md (brew/apt/pacman/dnf install $name)"
    else
        d_warn "$(printf '%-10s not found (optional)' "$name")"
    fi
}

# ── Shared read-only device detection (never exits) ──────────
# Echoes: state|model|android|api|abi|root
detect_device() {
    local state model android api abi root uid
    state="$(adb get-state 2>/dev/null | tr -d '\r' || true)"
    if [[ "$state" != "device" ]]; then echo "none|||||"; return; fi
    model="$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
    android="$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')"
    api="$(adb shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')"
    abi="$(adb shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r')"
    uid="$(adb shell id 2>/dev/null | tr -d '\r')"
    if echo "$uid" | grep -q "uid=0"; then root="yes (adb root)"
    elif adb shell "su 0 id" 2>/dev/null | grep -q "uid=0"; then root="yes (su)"
    elif adb shell "su -c id" 2>/dev/null | grep -q "uid=0"; then root="yes (su)"
    else root="no"; fi
    echo "device|$model|$android|$api|$abi|$root"
}

# ── doctor : comprehensive read-only health check ────────────
cmd_doctor() {
    local script_dir="$SCRIPT_DIR"
    echo ""
    echo -e "  ${C_BOLD}BurpNinja Doctor${C_RESET}  ${C_GRAY}read-only environment health check · v${VERSION}${C_RESET}"

    section "System"
    d_pass "$(printf '%-10s %s' OS "$(uname -s) $(uname -m)")"
    d_pass "$(printf '%-10s %s' shell "bash ${BASH_VERSION}")"
    if [[ $EUID -eq 0 ]]; then d_pass "$(printf '%-10s %s' privileges root)"
    else d_pass "$(printf '%-10s %s' privileges "user ($(id -un))")"; fi

    section "Tools"
    d_tool req adb      adb --version
    d_tool req python3  python3 --version
    d_tool req openssl  openssl version
    d_tool opt frida    frida --version
    d_tool opt objection objection version
    d_tool opt jadx     jadx --version
    d_tool opt apktool  apktool --version
    d_tool opt scrcpy   scrcpy --version
    d_tool opt xz       xz --version

    section "Android"
    if command -v adb &>/dev/null; then
        local d; d="$(detect_device)"
        local state="${d%%|*}"
        if [[ "$state" == "device" ]]; then
            IFS='|' read -r _ model android api abi root <<< "$d"
            d_pass "$(printf '%-10s %s' device "${model:-unknown}")"
            d_pass "$(printf '%-10s %s' android "${android:-?} / API ${api:-?}")"
            d_pass "$(printf '%-10s %s' abi "${abi:-?}")"
            if [[ "$root" == yes* ]]; then d_pass "$(printf '%-10s %s' root "$root")"
            else
                d_fail "$(printf '%-10s %s' root no)"
                d_fix "Device is not rooted" \
                      "System-cert install and frida-server require root" \
                      "Use a rooted device/emulator (rootAVD, Genymotion, Magisk)"
            fi
        else
            d_none "$(printf '%-10s %s' device "none connected")"
            d_fix "No ADB device detected" \
                  "Device off/unplugged, USB debugging off, or unauthorized" \
                  "Connect + authorize the device, or start an emulator; see references/adb.md"
        fi
    else
        d_none "device      (adb not installed)"
    fi

    section "Burp Suite"
    if command -v curl &>/dev/null && \
       curl -s --max-time 4 "http://${BURP_IP}/" 2>/dev/null | grep -qi "burp\|proxy"; then
        d_pass "$(printf '%-10s %s' listener "${BURP_IP} reachable")"
    else
        d_none "$(printf '%-10s %s' listener "${BURP_IP} not reachable")"
        d_fix "Burp proxy not reachable at ${BURP_IP}" \
              "Burp not running, or listener bound to a different host/port" \
              "Start Burp; Proxy > Options > listener ${BURP_IP} (all interfaces for LAN devices)"
    fi

    section "Frida"
    local pc_ver dev_ver
    pc_ver="$(command -v frida &>/dev/null && frida --version 2>/dev/null | tr -d '\r' || echo '')"
    [[ -n "$pc_ver" ]] && d_pass "$(printf '%-10s %s' client "$pc_ver")" \
                       || d_warn "$(printf '%-10s %s' client "not installed")"
    dev_ver=""
    if command -v adb &>/dev/null && [[ "$(adb get-state 2>/dev/null | tr -d '\r')" == "device" ]]; then
        for loc in /data/local/tmp/frida-server /system/xbin/frida-server; do
            if adb shell "test -f $loc" &>/dev/null; then
                dev_ver="$(adb shell "$loc --version" 2>/dev/null | tr -d '\r')"; break
            fi
        done
        if [[ -n "$dev_ver" ]]; then
            d_pass "$(printf '%-10s %s' server "$dev_ver")"
            if [[ -n "$pc_ver" && "$pc_ver" != "$dev_ver" ]]; then
                d_fail "$(printf '%-10s %s' match "client $pc_ver != server $dev_ver")"
                d_fix "Frida client/server version mismatch" \
                      "PC and device Frida versions differ" \
                      "Run BurpNinja menu [5] (Fix Frida Version Mismatch)"
            elif [[ -n "$pc_ver" ]]; then
                d_pass "$(printf '%-10s %s' match "in sync ($pc_ver)")"
            fi
        else
            d_none "$(printf '%-10s %s' server "not on device")"
        fi
    else
        d_none "$(printf '%-10s %s' server "no device")"
    fi

    section "Security"
    d_pass "downloads use HTTPS"
    d_warn "no checksum/signature verification of downloaded binaries yet (roadmap)"

    echo ""
    echo -e "  ${C_GRAY}────────────────────────────────────────────────${C_RESET}"
    echo -e "  Summary: ${C_GREEN}${D_PASS} pass${C_RESET} · ${C_YELLOW}${D_WARN} warn${C_RESET} · ${C_RED}${D_FAIL} fail${C_RESET} · ${C_GRAY}${D_NONE} n/a${C_RESET}"
    $VERBOSE && echo -e "  ${C_GRAY}scripts: $script_dir${C_RESET}"
    echo ""
    [[ $D_FAIL -gt 0 ]] && return 1 || return 0
}

# ── status : compact READY dashboard (read-only) ─────────────
cmd_status() {
    echo ""
    echo -e "  ${C_BOLD}BurpNinja${C_RESET}  ${C_GRAY}Android Security Testing Toolkit · v${VERSION}${C_RESET}"
    echo ""
    local dev="not connected" andr="—" root="—" adbs="not found" burp="not reachable" frida_c="not installed" proxy="$BURP_IP"
    command -v adb &>/dev/null && adbs="installed"
    local d; d="$(detect_device)"
    if [[ "${d%%|*}" == "device" ]]; then
        IFS='|' read -r _ model android api rroot <<< "$d"; :
        # re-parse with abi
        IFS='|' read -r _ model android api abi rroot <<< "$d"
        dev="$model"; andr="${android} / API ${api}"; root="$rroot"; adbs="connected"
    fi
    command -v frida &>/dev/null && frida_c="$(frida --version 2>/dev/null | tr -d '\r')"
    command -v curl &>/dev/null && curl -s --max-time 3 "http://${BURP_IP}/" 2>/dev/null | grep -qi "burp\|proxy" && burp="connected"
    printf "  %-12s %s\n" "Device"  "$dev"
    printf "  %-12s %s\n" "Android" "$andr"
    printf "  %-12s %s\n" "Root"    "$root"
    printf "  %-12s %s\n" "ADB"     "$adbs"
    printf "  %-12s %s\n" "Burp"    "$burp"
    printf "  %-12s %s\n" "Frida"   "$frida_c"
    printf "  %-12s %s\n" "Proxy"   "$proxy"
    echo ""
    echo -e "  ${C_GRAY}Run './BurpNinja.sh doctor' for a full health check, or './BurpNinja.sh' for the menu.${C_RESET}"
    echo ""
}

# ── setup : guided full install (honors --dry-run/--safe) ────
cmd_setup() {
    if $SAFE_MODE; then
        warn "Safe mode: read-only. Running diagnostics instead of setup."
        cmd_doctor; return $?
    fi
    if $DRY_RUN; then
        section "Setup plan (dry-run — no changes made)"
        would "verify internet connectivity"
        would "verify Burp proxy at ${BURP_IP}"
        would "verify ADB device + root access"
        would "install PC tools (jadx, apktool, scrcpy, frida, objection)"
        would "install Android helper apps (ProxyToggle, ProxyDroid, ADBWifi, F-Droid, Aurora)"
        would "install/verify frida-server for the device ABI"
        would "install the Burp CA certificate into the system trust store"
        echo ""
        info "Dry-run complete. Re-run 'setup' without --dry-run to apply."
        return 0
    fi
    check_root
    install_all
}

# ── help ─────────────────────────────────────────────────────
cmd_help() {
    cat <<EOF

  BurpNinja v${VERSION} — Android Security Testing Toolkit
  Author: @altafpasha

  USAGE
    ./BurpNinja.sh [command] [options]
    ./BurpNinja.sh                 Launch the interactive menu (default)

  COMMANDS
    doctor       Read-only environment health check (System/Tools/Android/Burp/Frida)
    status       Compact readiness dashboard
    setup        Guided full install (internet, Burp, ADB, tools, frida, cert)
    menu         Launch the interactive menu explicitly
    version      Print the version
    help         Show this help

  OPTIONS
    --dry-run    Show what would happen; make no changes
    --safe       Diagnostic-only mode (read-only; no install/config)
    --verbose    Extra detail in output
    --debug      Trace execution (implies --verbose)
    -h, --help   Show this help
    -v, --version  Print the version

  EXAMPLES
    ./BurpNinja.sh doctor            Check if the environment is ready
    ./BurpNinja.sh status            Quick device/Burp/Frida snapshot
    ./BurpNinja.sh setup --dry-run   Preview setup steps, change nothing
    ./BurpNinja.sh                   Full interactive menu (unchanged)

  TROUBLESHOOTING
    Only the banner prints then it exits  ->  run: TERM=xterm ./BurpNinja.sh
    A menu action quits the whole script  ->  a precondition failed; run 'doctor'
    Linux "Run as root"                   ->  use: sudo bash BurpNinja.sh

  Docs & AI skill: .claude/skills/run-burpninja/  ·  AGENTS.md

EOF
}

cmd_version() { echo "BurpNinja v${VERSION}"; }

# ── argument dispatcher ──────────────────────────────────────
main() {
    local cmd=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)          DRY_RUN=true ;;
            --safe|--safe-mode) SAFE_MODE=true ;;
            --verbose)          VERBOSE=true ;;
            --debug)            DEBUG=true; VERBOSE=true ;;
            -h|--help|help)     cmd="help" ;;
            -v|--version|version) cmd="version" ;;
            doctor|status|setup|menu) cmd="$1" ;;
            *)
                if [[ -z "$cmd" ]]; then
                    err "Unknown command or option: $1"
                    cmd="help"
                fi
                ;;
        esac
        shift
    done

    $DEBUG && set -x

    case "$cmd" in
        help)    cmd_help ;;
        version) cmd_version ;;
        doctor)  cmd_doctor ;;
        status)  cmd_status ;;
        setup)   cmd_setup ;;
        menu)    check_root; main_menu ;;
        "")
            if $SAFE_MODE; then cmd_doctor
            else check_root; main_menu; fi
            ;;
    esac
}

# ─────────────────────────────────────────
#  ENTRY
# ─────────────────────────────────────────
main "$@"