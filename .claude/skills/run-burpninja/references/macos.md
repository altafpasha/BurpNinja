# macOS

**Purpose:** run BurpNinja on macOS (Apple Silicon M1–M4 & Intel).

**Verified on:** this skill was built and driven on macOS 26.6.2, arm64,
bash 3.2, Homebrew 6.0.20, with adb, frida 17.17.0, objection 1.12.5,
jadx 1.5.6, apktool 3.0.3, scrcpy 4.1, openssl 3.6.3 all present.

## Prerequisites

[Homebrew](https://brew.sh). BurpNinja's `get_brew_cmd` finds brew at
`/opt/homebrew/bin/brew` (Apple Silicon) or `/usr/local/bin/brew` (Intel).

```bash
# Install Homebrew if missing:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# One-shot dependency install (from the repo README):
brew install android-platform-tools openssl python xz
```

## Detection

```bash
.claude/skills/run-burpninja/driver.sh doctor
```

The `[ Host ]` block shows `OS Darwin`, the arch, and the macOS version; the
`[ PC tools ]` block reports each tool's version or `MISSING`.

## Setup / Usage

```bash
cd /path/to/BurpNinja
chmod +x BurpNinja.sh
./BurpNinja.sh
```

**Do NOT use `sudo` on macOS.** `check_root` detects Darwin and runs as the
standard user so Homebrew and pip stay in user space:

```
[*] Running on macOS (Apple). Standard permissions.
```

Running under `sudo` breaks brew/pip ownership.

## Verification

```bash
.claude/skills/run-burpninja/driver.sh menu 3   # PC tools detection
.claude/skills/run-burpninja/driver.sh tui      # live menu; then: send 3 / capture / kill
```

## Troubleshooting (macOS-specific)

- **`TERM environment variable not set.` then the script exits** — a headless
  shell has no TERM, so `clear` fails under `set -e`. Use
  `TERM=xterm bash BurpNinja.sh` or the driver (which forces it).
- **`zsh: permission denied: ./BurpNinja.sh`** → `chmod +x BurpNinja.sh`.
- **`brew: command not found` (Apple Silicon)** →
  `eval "$(/opt/homebrew/bin/brew shellenv)"`.
- **`adb: command not found`** → `brew install android-platform-tools`, or add
  the SDK: `export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"`.
  BurpNinja already pre-seeds these SDK paths in its own PATH line.
- **"Allow accessory to connect?" prompt** on Ventura/Sonoma/Sequoia when a
  USB device is plugged in → click **Allow** so adb can see the device.
- **bash 3.2** — stock macOS bash is old; `bash -n BurpNinja.sh` still passes
  and the driver avoids bash-4 syntax.

## Limitations

macOS runs the PC side natively, but the device work still requires a
connected **rooted** Android device or emulator (AVD/Genymotion). `frida
-U`/`frida-ls-devices` need a real TTY on macOS — drive them via
`driver.sh tui`.
