#!/usr/bin/env bash
# ============================================================
#  ██████╗ ██╗   ██╗██████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗     ██╗ █████╗
#  ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║     ██║██╔══██╗
#  ██████╔╝██║   ██║██████╔╝██████╔╝██╔██╗ ██║██║██╔██╗ ██║     ██║███████║
#  ██╔══██╗██║   ██║██╔══██╗██╔═══╝ ██║╚██╗██║██║██║╚██╗██║██   ██║██╔══██║
#  ██████╔╝╚██████╔╝██║  ██║██║     ██║ ╚████║██║██║ ╚████║╚█████╔╝██║  ██║
#  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═╝
# ============================================================
#  Android Pentesting Setup Toolkit  |  Linux Edition
#  Author  : @altafpasha
#  Version : 2.0.0
# ============================================================

set -euo pipefail

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
BASE_DIR="/tmp/burpninja_workspace"
LOG_FILE="/tmp/burpninja_log.txt"
AI_ENABLED=false
ANTHROPIC_KEY=""
VERSION="2.0.0"

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
#  ROOT CHECK
# ─────────────────────────────────────────
check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "Run as root: sudo bash BurpNinja.sh"
        exit 1
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
        echo -e "   ${C_WHITE}Android Pentesting Setup Toolkit${C_RESET}  ${C_GRAY}│  Linux Edition  │  v${VERSION}${C_RESET}  ${C_MAGENTA}│  AI: ON ✦${C_RESET}"
    else
        echo -e "   ${C_WHITE}Android Pentesting Setup Toolkit${C_RESET}  ${C_GRAY}│  Linux Edition  │  v${VERSION}  │  AI: OFF${C_RESET}"
    fi
    echo -e "   ${C_GRAY}Author: @altafpasha${C_RESET}"
    echo -e "${C_GRAY}  ─────────────────────────────────────────────────────────────────────────${C_RESET}"
    echo ""
}

# ─────────────────────────────────────────
#  DEPENDENCY CHECK
# ─────────────────────────────────────────
require() {
    command -v "$1" &>/dev/null || { err "$1 not found. Install it first."; exit 1; }
}

install_pkg() {
    local pkg="$1"
    if command -v apt-get &>/dev/null; then
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

    $AI_ENABLED || return

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

test_burpsuite() {
    section "Burp Suite Proxy"
    local try_connect
    try_connect() {
        curl -s --max-time 5 "http://$1/" 2>/dev/null | grep -q "Burp\|200\|proxy" && return 0 || return 1
    }

    if try_connect "$BURP_IP"; then
        ok "Burp Suite running at $BURP_IP"
        return
    fi

    err "Burp Suite not detected at $BURP_IP"
    ai_analyze "Burp proxy unreachable" "curl http://${BURP_IP}/" "Connection refused"

    read -rp "  Enter Burp proxy (e.g. 192.168.1.10:8080): " custom_ip
    if try_connect "$custom_ip"; then
        BURP_IP="$custom_ip"
        ok "Burp Suite running at $BURP_IP"
    else
        err "Cannot reach Burp at $custom_ip. Exiting."
        exit 1
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
    root_test=$(timeout 6 adb shell "su -c 'echo __root_ok__'" 2>/dev/null || true)
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
    # Auto-install OpenSSL if missing
    if ! command -v openssl &>/dev/null; then
        warn "OpenSSL not found. Attempting auto-install..."
        install_pkg openssl

        # Re-check after install attempt
        if ! command -v openssl &>/dev/null; then
            err "OpenSSL could not be installed automatically."
            err "Install manually: apt install openssl  OR  pacman -S openssl  OR  dnf install openssl"
            ai_analyze "OpenSSL missing" "command -v openssl" "not found"
            return
        fi
        ok "OpenSSL installed successfully"
    fi

    local cert_exists
    cert_exists=$(adb shell "su -c 'ls /system/etc/security/cacerts/'" 2>/dev/null | grep "9a5ba575.0" || true)

    local proceed="y"
    if [[ -n "$cert_exists" ]]; then
        warn "Existing Burp cert found (9a5ba575.0)"
        read -rp "  Replace it? [Y/N]: " proceed
    fi

    [[ "$proceed" =~ ^[Yy]$ ]] || { info "Certificate unchanged"; return; }

    info "Downloading certificate from Burp..."
    if ! curl -s --max-time 10 "http://${BURP_IP}/cert" -o cacert.der; then
        err "Failed to download certificate"
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
    adb shell "su -c 'mount -o rw,remount /system'" >/dev/null 2>&1 || true

    adb shell "su -c 'mv /sdcard/${cert_name} /system/etc/security/cacerts/'" >/dev/null 2>&1
    adb shell "su -c 'chmod 644 /system/etc/security/cacerts/${cert_name}'" >/dev/null 2>&1
    adb shell "su -c 'chown root:root /system/etc/security/cacerts/${cert_name}'" >/dev/null 2>&1

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

    install_apk \
        "com.kinandcarta.create.proxytoggle" "ProxyToggle" \
        "https://github.com/theappbusiness/android-proxy-toggle/releases/download/v1.0.1/Proxy.Toggle.v1.0.1.zip" \
        "proxytoggle.zip"
    # zip needs unzip
    if [[ -f "proxytoggle.zip" ]]; then
        unzip -o proxytoggle.zip proxy-toggle.apk -d . >/dev/null 2>&1 || true
        adb install -t -r proxy-toggle.apk >/dev/null 2>&1 || true
        adb shell "pm grant com.kinandcarta.create.proxytoggle android.permission.WRITE_SECURE_SETTINGS" >/dev/null 2>&1 || true
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
        "https://gitlab.com/AuroraOSS/AuroraStore/-/releases/permalink/latest/downloads/app-release.apk" \
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
        local ver
        ver=$(curl -sI "https://github.com/skylot/jadx/releases/latest" | grep -i location | sed 's/.*\/v//' | tr -d '\r\n')
        curl -sL "https://github.com/skylot/jadx/releases/download/v${ver}/jadx-${ver}.zip" -o jadx.zip --max-time 120
        unzip -o jadx.zip -d /opt/jadx >/dev/null 2>&1 || true
        ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx 2>/dev/null || true
        ln -sf /opt/jadx/bin/jadx-gui /usr/local/bin/jadx-gui 2>/dev/null || true
        ok "jadx installed"
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
        result=$($PIP install frida frida-tools objection 2>&1 || true)
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
    curl -sI "https://github.com/$1/releases/latest" 2>/dev/null \
        | grep -i location \
        | sed 's/.*\/v//' \
        | tr -d '\r\n' || echo ""
}

install_magisk_module() {
    local ver
    ver=$(get_latest_github_release "ViRb3/magisk-frida")
    info "Downloading MagiskFrida v${ver}..."
    curl -sL "https://github.com/ViRb3/magisk-frida/releases/download/v${ver}/MagiskFrida-${ver}.zip" \
        -o frida_module.zip --max-time 120
    adb push frida_module.zip /data/local/tmp/ >/dev/null 2>&1
    adb shell "su -c 'magisk --install-module /data/local/tmp/frida_module.zip'" >/dev/null 2>&1
    ok "MagiskFrida module installed"

    info "Downloading TrustUserCerts module..."
    curl -sL "https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip" \
        -o trust_module.zip --max-time 60
    adb push trust_module.zip /data/local/tmp/ >/dev/null 2>&1
    adb shell "su -c 'magisk --install-module /data/local/tmp/trust_module.zip'" >/dev/null 2>&1
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

    local ver
    ver=$(get_latest_github_release "frida/frida")
    info "Frida v${ver} for ${arch} detected"

    local url="https://github.com/frida/frida/releases/download/${ver}/frida-server-${ver}-android-${arch}.xz"
    curl -sL "$url" -o frida-server.xz --max-time 300
    xz -d frida-server.xz 2>/dev/null || true

    local binary="frida-server-${ver}-android-${arch}"
    [[ ! -f "$binary" ]] && binary="frida-server"

    adb push "$binary" /data/local/tmp/frida-server >/dev/null 2>&1
    adb shell "su -c 'chmod 755 /data/local/tmp/frida-server'" >/dev/null 2>&1
    adb shell "su -c 'mount -o rw,remount /system'" >/dev/null 2>&1 || true
    adb shell "su -c 'cp /data/local/tmp/frida-server /system/xbin/frida-server'" >/dev/null 2>&1
    ok "Frida server installed at /system/xbin/frida-server"
    echo -e "  ${C_DCYAN}Start: adb shell \"su -c 'frida-server &'\"${C_RESET}"
}

install_frida_android() {
    section "Frida Server (Android)"
    local existing
    existing=$(adb shell "frida-server --version" 2>/dev/null || true)

    if [[ -n "$existing" ]]; then
        warn "Frida already installed: $existing"
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
    adb_ver=$(adb shell "frida-server --version" 2>/dev/null | tr -d '\r\n' || echo "not installed")

    echo -e "  Latest   : ${C_WHITE}${latest}${C_RESET}"
    [[ "$pc_ver"  == "$latest" ]] && echo -e "  PC       : ${C_GREEN}${pc_ver}${C_RESET}"  || echo -e "  PC       : ${C_YELLOW}${pc_ver}${C_RESET}"
    [[ "$adb_ver" == "$latest" ]] && echo -e "  Android  : ${C_GREEN}${adb_ver}${C_RESET}" || echo -e "  Android  : ${C_YELLOW}${adb_ver}${C_RESET}"
    echo ""

    if [[ "$pc_ver" == "$adb_ver" ]]; then
        ok "Versions in sync ($pc_ver)"
        return
    fi

    local PIP
    PIP=$(command -v pip3 || command -v pip)
    [[ "$pc_ver" != "$latest" ]] && { info "Upgrading PC frida..."; $PIP install frida frida-tools --upgrade -q; }
    [[ "$adb_ver" != "$latest" ]] && install_frida_android
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
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local bypass_src="$script_dir/bypass.js"
    local bypass_dst="$BASE_DIR/bypass.js"

    if [[ -f "$bypass_src" ]]; then
        cp "$bypass_src" "$bypass_dst"
        info "Using bypass.js from repo: $bypass_src"
    else
        # Inline fallback
        cat > "$bypass_dst" << 'BYPASS_EOF'
Java.perform(function () {
    console.log("[+] BurpNinja SSL Bypass Active");
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
});
BYPASS_EOF
        info "bypass.js written to: $bypass_dst"
    fi

    # ── Restart ADB ─────────────────────────────────
    info "Restarting ADB..."
    adb kill-server &>/dev/null || true
    adb start-server &>/dev/null || true
    adb wait-for-device &>/dev/null || true

    # ── Forward Frida ports ─────────────────────────
    info "Forwarding Frida ports (27042, 27043)..."
    adb forward tcp:27042 tcp:27042 &>/dev/null || true
    adb forward tcp:27043 tcp:27043 &>/dev/null || true

    # ── Request root ──────────────────────────────────
    info "Requesting ADB root..."
    adb root &>/dev/null || true
    sleep 2

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
    adb shell "pkill frida-server" &>/dev/null || true
    sleep 1

    # ── Start frida-server ─────────────────────────────
    info "Starting frida-server..."
    adb shell "su -c '$frida_bin &'" &>/dev/null || true
    sleep 3

    # ── Check PC frida ──────────────────────────────────
    if ! command -v frida &>/dev/null; then
        err "frida not found on PC. Run option [3] to install Frida tools first."
        return
    fi

    # ── Inject ─────────────────────────────────────────
    ok "Injecting SSL bypass into: $package"
    echo ""
    echo -e "  ${C_DCYAN}CMD: frida -H 127.0.0.1:27042 -f $package -l bypass.js --no-pause${C_RESET}"
    echo ""
    frida -H 127.0.0.1:27042 -f "$package" -l "$bypass_dst" --no-pause
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

# ─────────────────────────────────────────
#  ENTRY
# ─────────────────────────────────────────
check_root
main_menu