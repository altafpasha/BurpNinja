```text
  ██████╗ ██╗   ██╗██████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗     ██╗ █████╗ 
  ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║     ██║██╔══██╗
  ██████╔╝██║   ██║██████╔╝██████╔╝██╔██╗ ██║██║██╔██╗ ██║     ██║███████║
  ██╔══██╗██║   ██║██╔══██╗██╔═══╝ ██║╚██╗██║██║██║╚██╗██║██   ██║██╔══██║
  ██████╔╝╚██████╔╝██║  ██║██║     ██║ ╚████║██║██║ ╚████║╚█████╔╝██║  ██║
  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═╝
```

# BurpNinja

<div align="center">

**Android Bug Hunting Lab Setup Toolkit**

[![Windows](https://img.shields.io/badge/Windows-PowerShell%205.1+-blue?logo=windows)](#windows-guide)
[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon%20%26%20Intel-lightgrey?logo=apple)](#macos-guide-how-to-use-on-macos)
[![Linux](https://img.shields.io/badge/Linux-Bash-orange?logo=linux)](#linux-guide)
[![Version](https://img.shields.io/badge/Version-2.2.0-green)](#)
[![Author](https://img.shields.io/badge/Author-@altafpasha-purple)](#)

*Stop wasting time on lab setup — get your Android bug hunting environment ready in minutes.*

</div>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
  - [macOS](#macos-requirements)
  - [Linux](#linux-requirements)
  - [Windows](#windows-requirements)
- [Installation & How to Use](#installation--how-to-use)
  - [macOS Guide (How to Use on macOS)](#macos-guide-how-to-use-on-macos)
  - [Linux Guide](#linux-guide)
  - [Windows Guide](#windows-guide)
- [Menu Options](#menu-options)
- [Frida SSL Bypass](#frida-ssl-bypass)
- [AI Mode (Claude API)](#ai-mode-claude-api)
- [AI Agent Skill](#ai-agent-skill)
- [What Gets Installed](#what-gets-installed)
  - [PC Tools](#pc-tools)
  - [Android Apps](#android-apps)
  - [Frida Server](#frida-server)
- [Burp Certificate Setup](#burp-certificate-setup)
- [Device Requirements](#device-requirements)
- [Troubleshooting](#troubleshooting)
  - [macOS Specific Tips](#macos-specific-tips)
- [File Structure](#file-structure)
- [Disclaimer](#disclaimer)

---

## Overview

**BurpNinja** automates the repetitive lab setup that every Android bug hunter has to do before they can even start looking at an app.

Every new target means the same manual work — converting and pushing Burp certs, matching Frida versions, installing the same apps, fighting OpenSSL path issues. BurpNinja does all of it in one script so you can skip straight to hunting.

**What it sets up:**
- **Burp Suite CA certificate** installed into the Android system trust store — intercept HTTPS from any app
- **Frida server** matched to your device architecture — ready for dynamic analysis
- **One-click SSL pinning bypass** via `bypass.js` — so pinning doesn't block your research
- **Proxy helper apps and open-source app stores** pushed to the device
- **PC-side analysis tools** (JADX, Apktool, Scrcpy, Frida, Objection) installed and ready
- **AI-powered error analysis** via Claude — tells you exactly what broke and how to fix it (optional)

Available in two editions across all major operating systems:
| Edition | Script | Platform | Compatibility |
|---|---|---|---|
| **macOS** | `BurpNinja.sh` | Bash / Zsh | Apple Silicon (M1/M2/M3/M4) & Intel (x86_64) |
| **Linux** | `BurpNinja.sh` | Bash | Debian, Ubuntu, Kali, Arch, Fedora |
| **Windows** | `BurpNinja.ps1` | PowerShell 5.1+ | Windows 10 & 11 |

---

## Features

| # | Feature | Description |
|---|---|---|
| 1 | **Full Install** | Runs all setup steps in one go |
| 2 | **Burp Certificate** | Downloads, converts, and installs Burp CA into `/system/etc/security/cacerts/` |
| 3 | **PC Tools** | Installs JADX, Apktool, Scrcpy, Frida, Objection |
| 4 | **Frida Server** | Auto-detects Magisk or installs manually for any CPU arch |
| 5 | **Frida Version Sync** | Detects and fixes PC ↔ Android version mismatch |
| 6 | **Android Apps** | Installs ProxyToggle, ProxyDroid, ADB WiFi, F-Droid, Aurora Store |
| 7 | **Device Info** | Shows model, brand, Android version, API level, CPU ABI, serial |
| **8** | **🔥 Frida SSL Bypass** | Auto-starts frida-server and injects SSL pinning bypass |
| 9 | **AI Mode** | Claude API integration for real-time error diagnosis |

---

## Requirements

### macOS Requirements

BurpNinja runs natively on macOS (Apple Silicon M1/M2/M3/M4 & Intel) using [Homebrew](https://brew.sh).

| Tool | Purpose | Install via Homebrew |
|---|---|---|
| **Homebrew** | Package manager | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| **adb** | Communicate with device | `brew install android-platform-tools` |
| **openssl** | Convert Burp certificate | `brew install openssl` *(or auto-installed by script)* |
| **python3 & pip** | Install Frida & Objection | `brew install python` |
| **xz** | Extract Frida binaries | `brew install xz` |
| **curl & unzip** | Download & extract tools | Pre-installed on macOS |

> 💡 **Quick macOS Setup Command:**
> ```bash
> brew install android-platform-tools openssl python xz
> ```

### Linux Requirements

| Tool | Purpose | Debian / Ubuntu / Kali | Arch Linux | Fedora |
|---|---|---|---|---|
| **adb** | Communicate with device | `sudo apt install adb` | `sudo pacman -S android-tools` | `sudo dnf install android-tools` |
| **openssl** | Convert Burp certificate | `sudo apt install openssl` | `sudo pacman -S openssl` | `sudo dnf install openssl` |
| **python3-pip** | Install Frida & Objection | `sudo apt install python3-pip` | `sudo pacman -S python-pip` | `sudo dnf install python3-pip` |
| **xz-utils** | Extract Frida binary | `sudo apt install xz-utils` | `sudo pacman -S xz` | `sudo dnf install xz` |
| **curl & unzip** | Download & extract tools | `sudo apt install curl unzip` | `sudo pacman -S curl unzip` | `sudo dnf install curl unzip` |

### Windows Requirements

| Tool | Purpose | Install |
|---|---|---|
| **ADB** (Android Debug Bridge) | Communicate with device | [SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools) |
| **OpenSSL** | Convert Burp certificate | Auto-installed via Scoop/winget or [Win32 OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) |
| **Python 3** | Install Frida & Objection | [python.org](https://www.python.org/downloads/) |
| **Scoop** | Install JADX, Apktool, Scrcpy, OpenSSL | [scoop.sh](https://scoop.sh) |
| **7-Zip** | Extract Frida `.xz` binaries | [7-zip.org](https://www.7-zip.org/) |
| **PowerShell 5.1+** | Run the script | Built-in on Windows 10/11 |

---

## Installation & How to Use

### macOS Guide (How to Use on macOS)

BurpNinja is fully tested and optimized for macOS (supports Terminal, iTerm2, and Warp).

#### Step 1 — Install Homebrew (if not already installed)
If you don't have Homebrew installed, open Terminal and run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Step 2 — Install Recommended Dependencies
```bash
brew install android-platform-tools openssl python xz
```
*(BurpNinja will also attempt to auto-install missing packages via `brew` if needed)*

#### Step 3 — Enable USB Debugging on your Android Device
1. On your Android device, go to **Settings** → **About Phone** and tap **Build Number** 7 times to enable Developer Options.
2. Go to **Settings** → **Developer Options** → enable **USB Debugging**.
3. Connect the device to your Mac via USB. When macOS prompts *"Allow accessory to connect?"*, click **Allow**.
4. Confirm device is recognized:
   ```bash
   adb devices
   ```
   *(If you're using an Android emulator like Android Studio AVD or Genymotion, start the emulator and verify with `adb devices`)*

#### Step 4 — Start Burp Suite
Open Burp Suite on your Mac and ensure the proxy listener is running (default: `127.0.0.1:8080`).

#### Step 5 — Navigate to BurpNinja and Make Executable
Open Terminal, navigate to the BurpNinja folder, and grant execute permissions:
```bash
cd /path/to/BurpNinja
chmod +x BurpNinja.sh
```

#### Step 6 — Run BurpNinja
Run the script as your standard user:
```bash
./BurpNinja.sh
```

> ⚠️ **Important macOS Note:** Do **NOT** use `sudo` on macOS. Running as standard user (`./BurpNinja.sh`) allows Homebrew and Python environments to install and manage packages cleanly in your user space without permission conflicts.

#### Step 7 — Select an Option from the Interactive Menu
- Enter `1` for **Full Install** (installs Burp cert, tools, frida-server, and pentesting apps in one go).
- Enter `8` for **Frida SSL Bypass** to bypass SSL Pinning on your target app.

---

### Linux Guide

**Step 1 — Enable USB Debugging on your Android device**
> Settings → Developer Options → USB Debugging → ON

**Step 2 — Connect your device and verify ADB**
```bash
adb devices
```

**Step 3 — Start Burp Suite** and ensure listener is on `127.0.0.1:8080`.

**Step 4 — Make executable and run as root**
```bash
chmod +x BurpNinja.sh
sudo bash BurpNinja.sh
```

---

### Windows Guide

**Step 1 — Enable USB Debugging on your Android device**
> Settings → Developer Options → USB Debugging → ON

**Step 2 — Connect your device and verify ADB**
```powershell
adb devices
```

**Step 3 — Start Burp Suite** and ensure listener is on `127.0.0.1:8080`.

**Step 4 — Run BurpNinja as Administrator**
```powershell
powershell -ExecutionPolicy Bypass -File ".\BurpNinja.ps1"
```

> ⚠️ Must be run as **Administrator** (required to install system-level tools).

---

## Menu Options

```
  SETUP
  [1] Full Install (All)
  [2] Move Burp Certificate → Android System
  [3] PC Tools  (JADX · Apktool · Scrcpy · Frida · Objection)
  [4] Android Frida Server
  [5] Fix Frida Version Mismatch
  [6] Android Apps  (ProxyToggle · ProxyDroid · ADBWifi · F-Droid · Aurora)

  DEVICE
  [7] Device Info

  PENTEST
  [8] Frida SSL Bypass  (auto-start + inject)

  AI
  [9]  Enable AI Mode  (Claude API)
  [10] Disable AI Mode  (when enabled)

  [0] Exit
```

### Option Details

#### `[1]` Full Install
Runs all steps in sequence:
1. Internet check
2. Burp Suite proxy check
3. ADB + root check
4. PC tools install
5. Android apps install
6. Frida server install
7. Burp certificate install

#### `[2]` Burp Certificate
- Downloads the DER cert from `http://<burp-ip>/cert`
- Converts it to PEM using OpenSSL (auto-installs OpenSSL if missing)
- Computes the subject hash and renames to `<hash>.0`
- Pushes to `/system/etc/security/cacerts/` with correct permissions
- Prompts to replace if already installed

#### `[3]` PC Tools
**Windows (via Scoop):**
- `jadx` — Java/APK decompiler
- `apktool` — APK reverse engineering
- `scrcpy` — Android screen mirror/control

**Both platforms (via pip):**
- `frida` + `frida-tools` — dynamic instrumentation
- `objection` — runtime mobile exploration

#### `[4]` Frida Server
Auto-detects device setup:
- **Magisk detected** → installs MagiskFrida module + TrustUserCerts
- **No Magisk** → downloads correct architecture binary (`arm64`, `arm`, `x86_64`, `x86`) and installs to `/system/xbin/frida-server`

#### `[5]` Fix Frida Version Mismatch
Compares versions across PC, Android, and GitHub latest. Upgrades whichever is outdated.

#### `[6]` Android Apps
| App | Package | Purpose |
|---|---|---|
| **ProxyToggle** | `com.kinandcarta.create.proxytoggle` | Toggle system proxy on/off |
| **ProxyDroid** | `org.proxydroid` | Per-app proxy routing |
| **ADB WiFi** | `com.sujanpoudel.adbwifi` | Wireless ADB connection |
| **F-Droid** | `org.fdroid.fdroid` | Open-source app store |
| **Aurora Store** | `com.aurora.store` | Google Play alternative (no account needed) |

#### `[7]` Device Info
Displays: Model, Brand, Android version, API level, CPU ABI, Serial number.

---

## Frida SSL Bypass

Option `[8]` is BurpNinja's one-click SSL pinning bypass. It automates the full Frida injection workflow.

### How It Works

1. **Prompts for target package name** (e.g. `com.target.app`)
2. **Prepares `bypass.js`** — copies from repo, or writes inline fallback
3. **Restarts ADB** cleanly
4. **Forwards Frida ports** `27042` and `27043`
5. **Enables root** via `adb root`
6. **Auto-detects frida-server** at `/system/xbin/` or `/data/local/tmp/`
7. **Stops old frida-server** instance
8. **Starts fresh frida-server** in background
9. **Injects bypass** via `frida -U -f <package> -l bypass.js`

### What `bypass.js` Bypasses

| Target | Method |
|---|---|
| **Standard TrustManager** | Replaces with custom `X509TrustManager` that accepts all certs |
| **OkHttp3 CertificatePinner** | Hooks `check()` to silently pass |
| **Android 7+ NetworkSecurityConfig** | Hooks `RootTrustManager.checkServerTrusted` |

### Manual Usage

You can also run `bypass.js` directly without the menu:

```bash
# Start frida-server first
adb shell "nohup /data/local/tmp/frida-server >/dev/null 2>&1 &"

# Inject bypass
frida -U -f com.target.app -l bypass.js
```

> **Prerequisite:** Run option `[4]` first to install Frida server on the device, and option `[3]` to install Frida tools on PC.

---

## AI Mode (Claude API)

BurpNinja has an optional AI layer powered by **Anthropic Claude** that analyzes errors in real-time and suggests fixes.

### Enable AI Mode

1. Select `[9]` from the menu
2. Enter your Anthropic API key (`sk-ant-...`)
3. The key is validated with a test ping before activation

Get your API key at: https://console.anthropic.com

### How AI Mode Works

When an error occurs, BurpNinja automatically sends context to Claude:

```
CONTEXT: Burp cert download failed
COMMAND: curl http://127.0.0.1:8080/cert
OUTPUT:  curl: (7) Failed to connect
```

Claude responds with:

```
DIAGNOSIS: Burp Suite proxy not running or wrong port
FIX:       Start Burp Suite and ensure listener is on 127.0.0.1:8080
PREVENTION: Always start Burp before running BurpNinja
```

### AI Session Review

When AI is enabled, option `[9]` changes to **AI Session Review** — sends the entire session log to Claude for a full summary of what succeeded, what failed, and a prioritized action plan.

> 🔒 Your API key is **never saved to disk**. It exists only in memory for the current session.

---

## AI Agent Skill

BurpNinja ships with a **universal, agent-agnostic AI skill** so any AI coding
or security agent can run, configure, and troubleshoot it for you. It lives in
[`.claude/skills/run-burpninja/`](.claude/skills/run-burpninja/) and is plain
Markdown plus a portable bash driver — **no vendor API required** (works with
Claude Code, Cursor, Windsurf, Cline, Roo Code, Continue, Aider, Copilot,
Gemini CLI, Codex, OpenHands, Goose, and other Markdown/instruction-based
agents).

> This is different from **AI Mode** above. AI Mode is a *feature inside
> BurpNinja* (menu `[9]`, Anthropic key). The **skill** teaches an external
> agent how to drive BurpNinja, and needs no API key.

### What's in it

| File | Purpose |
|---|---|
| `SKILL.md` | Primary entry point — driver-first instructions, gotchas, safety |
| `driver.sh` | The harness: `doctor` / `check` / `menu` / `tui` / `send` / `capture` / `kill` |
| `references/*` | Deep per-topic docs (adb, burp, frida, ssl-pinning, per-OS, …) |
| `examples/*` | Walk-throughs (first-time setup, emulator, physical device, …) |
| `adapters/*` | Optional per-agent loading notes |

### How to use it

**Most agents discover it with zero setup** — the repo ships the standard
agent entry-point files at the root, and each points to the skill (single
source of truth, nothing to keep in sync):

| Root file | Read by |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Cross-tool standard — Codex, Cursor, Gemini CLI, Jules, **Antigravity**, Aider, Zed, Windsurf, Copilot, Devin, 30+ others |
| [`CLAUDE.md`](CLAUDE.md) + [`.claude/skills/run-burpninja/`](.claude/skills/run-burpninja/) | Claude Code (auto-loads as `/run-burpninja`) |
| [`GEMINI.md`](GEMINI.md) | Gemini CLI / Antigravity fallback |
| [`.github/copilot-instructions.md`](.github/copilot-instructions.md) | GitHub Copilot |

**Claude Code** auto-discovers the skill — it appears as `/run-burpninja` and
loads when you ask to "run BurpNinja", "set up the Android environment", or
"figure out why BurpNinja isn't working".

**Any other agent** — it likely reads `AGENTS.md` already; if not, point it at
`SKILL.md` (that file works standalone):

| Agent | Load it with |
|---|---|
| Codex / Antigravity / Cursor / Windsurf | auto via `AGENTS.md` |
| Cline / Roo / Continue | add `SKILL.md` to context / `@files` |
| GitHub Copilot | auto via `.github/copilot-instructions.md`, or `#file:…/SKILL.md` |
| Gemini CLI / Code Assist | auto via `AGENTS.md` / `GEMINI.md`, or `@…/SKILL.md` |
| Aider / other | auto via `AGENTS.md`, or `/read` the `SKILL.md` file |

### Drive it directly (macOS / Linux)

```bash
# read-only environment report — run this first
.claude/skills/run-burpninja/driver.sh doctor

# static sanity check of the scripts
.claude/skills/run-burpninja/driver.sh check

# drive the menu headlessly (e.g. [3] PC Tools), then it auto-exits
.claude/skills/run-burpninja/driver.sh menu 3

# launch the live menu in tmux, press a key, snapshot, quit
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 3
.claude/skills/run-burpninja/driver.sh capture
.claude/skills/run-burpninja/driver.sh kill
```

### Example prompts

- "Run BurpNinja and show me the menu."
- "Set up my Android pentest environment with BurpNinja."
- "BurpNinja isn't working — figure out why." *(runs `doctor`, doesn't reinstall)*
- "Check my Frida client/server versions are in sync."
- "Bypass SSL pinning on `com.example.app` — I own it."

Full details, security boundaries, and how to update the skill when BurpNinja
changes are in [`.claude/skills/run-burpninja/README.md`](.claude/skills/run-burpninja/README.md).

---

## What Gets Installed

### PC Tools

| Tool | Location (Windows) | Location (Linux) |
|---|---|---|
| jadx | Scoop shim | `/usr/local/bin/jadx` |
| apktool | Scoop shim | Package manager |
| scrcpy | Scoop shim | Package manager |
| frida-tools | Python global | Python global |
| objection | Python global | Python global |

### Android Apps

| App | Installed via |
|---|---|
| ProxyToggle | `adb install` |
| ProxyDroid | `adb install` |
| ADB WiFi | `adb install` |
| F-Droid | `adb install` |
| Aurora Store | `adb install` |

### Frida Server

| Method | Location on Device |
|---|---|
| Manual install | `/system/xbin/frida-server` |
| Magisk module | Managed by Magisk (auto-start on boot) |

**Start Frida server manually:**
```bash
adb shell "su -c 'frida-server &'"
```

**Check version:**
```bash
adb shell "su -c 'frida-server --version'"
```

---

## Burp Certificate Setup

BurpNinja installs the Burp CA as a **system-trusted certificate**, which means:
- It works for **all apps**, including those pinning to the system store
- It survives app updates
- No need for per-app VPN profiles

### Manual Alternative (if script fails)

```bash
# 1. Download cert from Burp
curl http://127.0.0.1:8080/cert -o cacert.der

# 2. Convert to PEM
openssl x509 -inform DER -in cacert.der -out cacert.pem

# 3. Get hash
HASH=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1)

# 4. Push to device
cp cacert.pem ${HASH}.0
adb push ${HASH}.0 /sdcard/
adb shell "su -c 'mount -o rw,remount /system'"
adb shell "su -c 'mv /sdcard/${HASH}.0 /system/etc/security/cacerts/'"
adb shell "su -c 'chmod 644 /system/etc/security/cacerts/${HASH}.0'"

# 5. Reboot
adb reboot
```

---

## Device Requirements

| Requirement | Details |
|---|---|
| **Root access** | Required — via Magisk, KernelSU, or `adb root` (emulators) |
| **USB Debugging** | Must be enabled in Developer Options |
| **Single device** | Only one ADB device/emulator connected at a time |
| **Android version** | Android 7+ recommended (API 24+) |

### Root Detection Logic

BurpNinja uses a two-tier root check:

1. **Tier 1** — `adb shell id` → if `uid=0`, ADB itself runs as root (emulators with `adb root`)
2. **Tier 2** — `su -c 'echo test'` with a 6-second timeout (Magisk / KernelSU devices)

### Supported Emulators

| Emulator | Root Method |
|---|---|
| Android Studio AVD | [rootAVD](https://github.com/newbit1/rootAVD) |
| Genymotion | Built-in root |
| BlueStacks | Root via settings |

---

## Troubleshooting

### `OpenSSL not found`
BurpNinja will **auto-install** OpenSSL via Scoop or winget (Windows) / apt/pacman/dnf (Linux) / Homebrew (macOS). If auto-install fails:
- **macOS:** `brew install openssl`
- **Windows:** `scoop install openssl` or download from https://slproweb.com/products/Win32OpenSSL.html
- **Linux:** `sudo apt install openssl`

### `adb: device not found`
- Check USB cable and enable USB Debugging
- Try `adb kill-server && adb start-server`
- Ensure only one device is connected

### `Frida version mismatch`
Use option `[5]` — Fix Frida Version Mismatch. It auto-upgrades both PC and Android sides.

### `su: Permission denied`
The device is not rooted or the Superuser app hasn't granted ADB access. Open the Superuser/Magisk app and approve the permission request.

### `frida-server not found on device`
Run option `[4]` first to install Frida server. Then retry option `[8]`.

### `Certificate not trusted by app`
Some apps use **SSL Pinning**. Use option `[8] Frida SSL Bypass` for automated bypass, or manually:
```bash
objection -g <package.name> explore
# inside objection:
android sslpinning disable
```

### `Burp proxy not detected`
- Start Burp Suite before running BurpNinja
- Go to Burp → Proxy → Options → verify listener is on `127.0.0.1:8080`
- If using a physical device on a different machine, use the machine's LAN IP

### macOS Specific Tips

#### `zsh: permission denied: ./BurpNinja.sh`
Ensure you have granted execution permissions to the script:
```bash
chmod +x BurpNinja.sh
```

#### `brew: command not found` (Apple Silicon M1/M2/M3/M4)
If Homebrew is installed but not in your PATH, add Homebrew to your environment:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### `adb: command not found` on macOS
If installed via Homebrew:
```bash
brew install android-platform-tools
```
Or if using Android Studio SDK, add it to your `~/.zshrc`:
```bash
echo 'export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### macOS "Allow accessory to connect?" Prompt
On macOS Ventura, Sonoma, and Sequoia, when plugging in your Android device via USB, macOS may display a system security dialog. Make sure to click **Allow** so ADB can communicate with the device.

### Banner shows garbled characters (Windows)
The script sets UTF-8 encoding automatically. If it still garbles:
```powershell
chcp 65001
```
Or switch to **Windows Terminal** instead of the legacy `cmd` / old PowerShell host.

---

## File Structure

```
BurpNinja/
├── BurpNinja.ps1    # Windows edition (PowerShell 5.1+)
├── BurpNinja.sh     # Linux & macOS edition (Bash / Zsh)
├── bypass.js        # Frida SSL pinning bypass script
├── README.md        # Documentation & usage guide
├── FIXES.md         # Changelog / bug fix notes
└── .gitignore       # Excludes certs, binaries, logs from git
```

---

## Disclaimer

> BurpNinja is a **lab setup tool** intended for Android bug bounty research and security education on devices you own or have explicit permission to test.
> Always practice responsible disclosure and comply with the scope and rules of the bug bounty program you are participating in.
> The author (`@altafpasha`) is not responsible for any misuse of this tool.

---

<div align="center">

Made with ☕ by [@altafpasha](https://github.com/altafpasha)

</div>
