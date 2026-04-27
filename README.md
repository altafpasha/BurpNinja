```
  ____                   _   _  _         _
 |  _ )_   _ _ __ _ __  | \ | |(_)_ __  (_) __ _
 | |_) | | | | '__| '_ \ |  \| || | '_ \ | |/ _`|
 |  _ <| |_| | |  | |_) || |\  || | | | || | (_| |
 |_|_\_\\__,_|_|  | .__/ |_| \_||_|_| |_||_|\__,_|
                   |_|
```

# BurpNinja

<div align="center">

**Android Pentesting Setup Toolkit**

[![Windows](https://img.shields.io/badge/Windows-PowerShell%205.1+-blue?logo=windows)](#windows-edition)
[![Linux](https://img.shields.io/badge/Linux-Bash-orange?logo=linux)](#linux-edition)
[![Version](https://img.shields.io/badge/Version-2.0.0-green)](#)
[![Author](https://img.shields.io/badge/Author-@altafpasha-purple)](#)

*Automate your Android pentest environment — Burp cert, Frida, SSL bypass, JADX, proxies — in one script.*

</div>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
  - [Windows](#windows-requirements)
  - [Linux](#linux-requirements)
- [Installation](#installation)
  - [Windows Edition](#windows-edition)
  - [Linux Edition](#linux-edition)
- [Menu Options](#menu-options)
- [Frida SSL Bypass](#frida-ssl-bypass)
- [AI Mode (Claude API)](#ai-mode-claude-api)
- [What Gets Installed](#what-gets-installed)
  - [PC Tools](#pc-tools)
  - [Android Apps](#android-apps)
  - [Frida Server](#frida-server)
- [Burp Certificate Setup](#burp-certificate-setup)
- [Device Requirements](#device-requirements)
- [Troubleshooting](#troubleshooting)
- [File Structure](#file-structure)
- [Disclaimer](#disclaimer)

---

## Overview

**BurpNinja** is a one-shot automation toolkit that sets up a complete Android pentesting environment. It handles:

- Installing the **Burp Suite CA certificate** into the Android system trust store
- Setting up **Frida** (via Magisk module or manual install)
- **One-click SSL pinning bypass** via Frida injection (`bypass.js`)
- Installing **proxy helper apps** and **app stores** on the device
- Installing **PC-side analysis tools** (JADX, Apktool, Scrcpy, Objection)
- **AI-powered error analysis** via Claude (optional)

Available in two editions:
| Edition | Script | Platform |
|---|---|---|
| **Windows** | `BurpNinja.ps1` | PowerShell 5.1+ |
| **Linux** | `BurpNinja.sh` | Bash (Debian/Arch/Fedora) |

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

### Windows Requirements

| Tool | Purpose | Install |
|---|---|---|
| **ADB** (Android Debug Bridge) | Communicate with device | [SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools) |
| **OpenSSL** | Convert Burp certificate | Auto-installed via Scoop/winget or [Win32 OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) |
| **Python 3** | Install Frida & Objection | [python.org](https://www.python.org/downloads/) |
| **Scoop** | Install JADX, Apktool, Scrcpy, OpenSSL | [scoop.sh](https://scoop.sh) |
| **7-Zip** | Extract Frida `.xz` binaries | [7-zip.org](https://www.7-zip.org/) |
| **PowerShell 5.1+** | Run the script | Built-in on Windows 10/11 |

> **Note:** OpenSSL is now auto-installed via Scoop or winget if missing — no manual setup needed.

### Linux Requirements

| Tool | Purpose | Install |
|---|---|---|
| **adb** | Communicate with device | `apt install adb` |
| **openssl** | Convert Burp certificate | Auto-installed via apt/pacman/dnf if missing |
| **curl** | Download files | `apt install curl` |
| **python3-pip** | Install Frida & Objection | `apt install python3-pip` |
| **unzip** | Extract APK zips | `apt install unzip` |
| **xz-utils** | Extract Frida binary | `apt install xz-utils` |

---

## Installation

### Windows Edition

**Step 1 — Enable USB Debugging on your Android device**
> Settings → Developer Options → USB Debugging → ON

**Step 2 — Connect your device and verify ADB**
```powershell
adb devices
```
You should see your device listed as `device`.

**Step 3 — Start Burp Suite** and ensure the proxy is running at `127.0.0.1:8080` (or your preferred IP/port).

**Step 4 — Run BurpNinja as Administrator**
```powershell
powershell -ExecutionPolicy Bypass -File ".\BurpNinja.ps1"
```

> ⚠️ Must be run as **Administrator** (required to install system-level tools).

---

### Linux Edition

**Step 1 — Make the script executable**
```bash
chmod +x BurpNinja.sh
```

**Step 2 — Run as root**
```bash
sudo bash BurpNinja.sh
```

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
9. **Injects bypass** via `frida -H 127.0.0.1:27042 -f <package> -l bypass.js --no-pause`

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
adb shell "su -c '/system/xbin/frida-server &'"

# Inject bypass
frida -H 127.0.0.1:27042 -f com.target.app -l bypass.js --no-pause
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
BurpNinja will **auto-install** OpenSSL via Scoop or winget (Windows) / apt/pacman/dnf (Linux). If auto-install fails:
- **Windows:** `scoop install openssl` or download from https://slproweb.com/products/Win32OpenSSL.html
- **Linux:** `apt install openssl`

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
├── BurpNinja.sh     # Linux edition (Bash)
├── bypass.js        # Frida SSL pinning bypass script
├── README.md        # This file
├── FIXES.md         # Changelog / bug fix notes
└── .gitignore       # Excludes certs, binaries, logs from git
```

---

## Disclaimer

> This tool is intended for **authorized security testing and educational purposes only**.
> Use BurpNinja only on devices and networks you own or have explicit written permission to test.
> The author (`@altafpasha`) is not responsible for any misuse or damage caused by this tool.
> Always comply with applicable laws and responsible disclosure guidelines.

---

<div align="center">

Made with ☕ by [@altafpasha](https://github.com/altafpasha)

</div>
