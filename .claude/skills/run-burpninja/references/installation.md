# Installation

**Purpose:** get BurpNinja and its PC-side dependencies onto the operator's
machine. BurpNinja auto-installs most tools from its menu (`install_pkg`
picks the right package manager), but a small base set must exist first.

**Prerequisites:** git or a downloaded copy of the repo; a supported OS.

## Get BurpNinja

```bash
git clone https://github.com/altafpasha/BurpNinja
cd BurpNinja
```

## Base dependencies BurpNinja expects

`BurpNinja.sh` needs, at minimum, a shell and `curl`; it then auto-installs
the rest via `install_pkg` (Homebrew/apt/pacman/dnf). The tools it manages:

| Tool | Purpose | Auto-installed by |
|---|---|---|
| adb | talk to the device | you / package manager |
| openssl | convert the Burp cert | menu `[2]` if missing |
| python3 + pip | frida-tools, objection | you |
| xz (Linux/macOS) / 7-Zip (Win) | extract frida-server | menu `[4]` if missing |
| frida, frida-tools, objection | instrumentation | menu `[3]` (pip) |
| jadx, apktool, scrcpy | RE tools | menu `[3]` |
| curl, unzip | downloads | pre-installed |

Per-OS exact commands: [`macos.md`](macos.md), [`linux.md`](linux.md),
[`windows.md`](windows.md).

## Detection

```bash
# From the repo root — read-only, no side effects:
.claude/skills/run-burpninja/driver.sh doctor
```

This is the fastest way to see what is already present and what BurpNinja will
need to install. Example output (this container, macOS arm64) showed adb,
frida 17.17.0, objection, jadx, apktool, scrcpy, openssl, python3, xz, curl,
unzip, git and brew all `OK`.

## Setup / Usage

```bash
chmod +x BurpNinja.sh
./BurpNinja.sh          # macOS (standard user)
sudo bash BurpNinja.sh  # Linux (root)
```

Then choose `[3] PC Tools` to install the PC side, and `[1] Full Install` to
run everything against a connected device.

## Verification

```bash
.claude/skills/run-burpninja/driver.sh check    # bash -n + node --check
.claude/skills/run-burpninja/driver.sh menu 3   # runs the PC-tools detection
```

`menu 3` on this container printed:

```
[+] Internet connection OK
[+] jadx already installed
[+] apktool already installed
[+] scrcpy already installed
[+] Frida and Objection already installed
```

## Troubleshooting

- **`clear`/banner aborts with a TERM error** → run `TERM=xterm bash
  BurpNinja.sh` or use `driver.sh menu`. (See [`troubleshooting.md`](troubleshooting.md).)
- **`pip install ... externally-managed-environment`** → BurpNinja already
  retries with `--break-system-packages`; if it still fails, use a venv.
- **Homebrew not on PATH (Apple Silicon)** → `eval "$(/opt/homebrew/bin/brew
  shellenv)"`.

## Limitations

The base set (shell + curl + a package manager) must exist before BurpNinja
can bootstrap the rest. On locked-down systems without a package manager,
`install_pkg` warns and you install manually.
