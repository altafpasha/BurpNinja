# Architecture

## What BurpNinja is

BurpNinja is a single-file interactive **TUI menu**, shipped in two parity
editions:

| File | Platform | Shell | Version string in repo |
|---|---|---|---|
| `BurpNinja.sh` | macOS & Linux | Bash (works on macOS bash 3.2) | `VERSION="2.1.0"` |
| `BurpNinja.ps1` | Windows 10/11 | PowerShell 5.1+ | `$script:Version = "2.0.0"` |
| `bypass.js` | device (Frida/ART) | Frida JS | header says `Version : 1.0` |

There is no build step, no package manifest, no test suite. "Running" it means
launching the menu and selecting numbered options. That is why the skill ships
a driver: an agent needs a programmatic handle on an interactive menu.

## Components

```
BurpNinja.sh / .ps1  (the menu + all logic)
        │
        ├── PC side: adb, frida, frida-tools, objection, jadx, apktool,
        │            scrcpy, openssl, python3/pip, xz (Linux/macOS) / 7-Zip (Win)
        │            installed via brew / apt / pacman / dnf / scoop / winget / pip
        │
        ├── Device side (over adb): Burp CA cert → /system/etc/security/cacerts/,
        │            frida-server → /data/local/tmp or /system/xbin,
        │            helper APKs (ProxyToggle, ProxyDroid, ADB WiFi, F-Droid, Aurora)
        │
        ├── bypass.js: Frida script injected into the target app
        │
        └── AI (optional): POST to https://api.anthropic.com/v1/messages
```

## Menu → function map (from `BurpNinja.sh`)

| # | Menu label | Function | Preconditions that can `exit` |
|---|---|---|---|
| 1 | Full Install (All) | `install_all` | internet, Burp, adb, root |
| 2 | Burp cert → Android | `install_cert` | internet, adb, root, Burp |
| 3 | PC Tools | `install_pc_tools` | internet |
| 4 | Android Frida Server | `install_frida_android` | internet, adb, root |
| 5 | Fix Frida Version Mismatch | `repair_frida_version` | internet, adb |
| 6 | Android Apps | `install_android_apps` | internet, adb |
| 7 | Device Info | `show_device_info` | adb |
| 8 | Frida SSL Bypass | `ssl_bypass` | adb (root), frida-server present |
| 9 | Enable AI / AI Session Review | `enable_ai` / `ai_log_review` | — |
| 10 | Disable AI Mode (when enabled) | inline | — |
| 0 | Exit | — | — |

The `test_internet`, `test_burpsuite`, `test_adb` helpers and the root check
**call `exit 1`** on failure, terminating the whole program (not just the
menu action). This is the single most important behavioral quirk — see
[`troubleshooting.md`](troubleshooting.md).

## Detection logic BurpNinja uses (mirror it before acting)

- **OS/arch:** `uname -s` (Darwin ⇒ macOS, standard user; else Linux, needs
  root). PATH is pre-seeded for Homebrew and the Android SDK.
- **Package manager:** first of `brew` → `apt-get` → `pacman` → `dnf`
  (Linux/macOS); `scoop` → `winget` (Windows).
- **Device ABI:** `adb shell getprop ro.product.cpu.abi` → maps
  `x86_64|x86|arm64|arm` to the Frida download name.
- **Root (two-tier):** `adb shell id` → `uid=0`? else `su 0 id` / `su -c id`.
- **Frida versions:** `frida --version` (PC) vs `frida-server --version`
  (device) vs GitHub latest (via `Location` redirect header).
- **Burp:** `curl http://127.0.0.1:8080/` looks for `Burp|200|proxy`.

`driver.sh doctor` reproduces all of this **read-only**.

## Required vs optional agent capabilities

**Required to be useful at all:** read files, understand Markdown, follow
multi-step procedures.

**Required to act automatically:** execute shell commands and read their
output.

**Optional (feature-gated, degrade gracefully):** filesystem write, `adb`,
`tmux`, `node`, browser, git, MCP, IDE integration, emulator control, and any
AI-analysis capability.

**Fallback contract** — when an optional capability is unavailable:

```
If terminal execution is available:
    run the command and interpret the output.
Otherwise:
    give the exact command to the user and ask them to paste the result.
```

Never assume a tool exists — probe with the detection above (or run
`driver.sh doctor`).

## Extensibility

References are modular so new BurpNinja features touch one file. For each new
capability, document it with this template:

```
Purpose · Prerequisites · Detection · Setup · Usage · Verification ·
Troubleshooting · Limitations
```

## Version awareness

The **repository is always authoritative** over this documentation. When you
operate against a newer BurpNinja:

1. Inspect the current `BurpNinja.sh` / `.ps1` / `bypass.js`.
2. Compare with what this skill claims; run `driver.sh doctor` / `check`.
3. Prefer current repo behavior.
4. Flag outdated documentation to the user.
5. Never blindly run a command from an old reference — confirm the function
   still exists (e.g. `grep -n install_frida_manual BurpNinja.sh`).

Observed drift already worth noting: the `.sh` edition is `2.1.0` and the
`.ps1` edition is `2.0.0`; `README.md` mentions a `FIXES.md` that is **not
present** in the repo. Always trust the scripts over prose.
