# Windows

**Purpose:** run BurpNinja on Windows 10/11 via `BurpNinja.ps1`.

> **Not runtime-verified.** This skill was built on macOS/Linux; `driver.sh`
> is a bash harness and does not drive the PowerShell edition. Everything here
> is derived from `BurpNinja.ps1` (authoritative) — verify against the current
> file before relying on it. There is no PowerShell driver in this skill; an
> agent on Windows should read `BurpNinja.ps1` directly and drive the menu
> with the platform's own means (e.g. run it in a real console).

## Prerequisites

| Tool | Purpose | Install |
|---|---|---|
| ADB | device comms | [SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools) |
| OpenSSL | convert Burp cert | auto via Scoop/winget, or [Win32 OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) |
| Python 3 | frida-tools, objection | [python.org](https://www.python.org/downloads/) |
| Scoop | jadx, apktool, scrcpy, openssl | [scoop.sh](https://scoop.sh) |
| 7-Zip | extract frida-server `.xz` | [7-zip.org](https://www.7-zip.org/) |
| PowerShell 5.1+ | run the script | built-in |

## Setup / Usage

```powershell
powershell -ExecutionPolicy Bypass -File ".\BurpNinja.ps1"
```

The script header declares `#Requires -RunAsAdministrator` — it must run
**as Administrator**. Menu numbering matches the `.sh` edition (`1`–`10`, `0`).

## Detection (manual, since the bash driver doesn't run here)

```powershell
adb get-state
frida --version
adb shell "frida-server --version"
Get-Command openssl, python, scoop, 7z -ErrorAction SilentlyContinue
```

## Notable differences from the `.sh` edition

- **PC tools** come from **Scoop** (`scoop bucket add extras`;
  `scoop install jadx apktool scrcpy`), not brew/apt.
- **frida-server extraction** uses **7-Zip** (`7z x frida-server.xz`); errors
  out if 7z is missing.
- **SSL bypass** starts frida-server via `su -c` and injects with
  `frida -H 127.0.0.1:27042 -f <pkg> -l bypass.js` (the `.sh` edition uses
  `frida -U -f <pkg> -l bypass.js`).
- **Aurora Store** URL differs (GitLab permalink) from the `.sh` edition.
- **Version string** is `2.0.0` (the `.sh` edition is `2.1.0`).

## Troubleshooting (Windows-specific)

- **Garbled banner** → the script sets UTF-8; if still broken run `chcp 65001`
  or use Windows Terminal instead of legacy `cmd`/old PowerShell host.
- **`openssl` not found** → `scoop install openssl` or winget
  `ShiningLight.OpenSSL`; the script attempts both and refreshes PATH.
- **`7-Zip not found`** → install 7-Zip and ensure `7z` is on PATH.
- **Execution policy blocks the script** → the launch command uses
  `-ExecutionPolicy Bypass`.

## Limitations

The bash `driver.sh` in this skill does not cover the PowerShell edition —
`doctor`/`menu`/`tui` are macOS/Linux only. On Windows, read `BurpNinja.ps1`
and drive it directly. All device requirements (rooted device/emulator) are
identical.
