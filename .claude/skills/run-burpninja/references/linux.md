# Linux

**Purpose:** run BurpNinja on Linux (Debian/Ubuntu/Kali, Arch, Fedora).

> Not runtime-verified in this build (the container was macOS). Commands below
> are taken from `BurpNinja.sh` and the repo README — authoritative source —
> but treat them as repo-derived. The bash logic is shared with the
> macOS path, which **was** driven here.

## Prerequisites

BurpNinja's `install_pkg` auto-detects `apt-get` → `pacman` → `dnf`. Base
tools per distro:

| Tool | Debian/Ubuntu/Kali | Arch | Fedora |
|---|---|---|---|
| adb | `sudo apt install adb` | `sudo pacman -S android-tools` | `sudo dnf install android-tools` |
| openssl | `sudo apt install openssl` | `sudo pacman -S openssl` | `sudo dnf install openssl` |
| pip | `sudo apt install python3-pip` | `sudo pacman -S python-pip` | `sudo dnf install python3-pip` |
| xz | `sudo apt install xz-utils` | `sudo pacman -S xz` | `sudo dnf install xz` |
| curl, unzip | `sudo apt install curl unzip` | `sudo pacman -S curl unzip` | `sudo dnf install curl unzip` |

## Detection

```bash
.claude/skills/run-burpninja/driver.sh doctor
```

## Setup / Usage

```bash
chmod +x BurpNinja.sh
sudo bash BurpNinja.sh
```

**Linux requires root.** `check_root` `exit 1`s with
`Run as root: sudo bash BurpNinja.sh` if `$EUID != 0` on a non-Darwin host.
(This differs from macOS, which must **not** use sudo.)

## Verification

```bash
.claude/skills/run-burpninja/driver.sh check
sudo -E TERM=xterm bash BurpNinja.sh   # -E keeps TERM; pick 3, then 0
```

## Troubleshooting (Linux-specific)

- **jadx has no brew** → BurpNinja downloads the latest jadx release zip and
  symlinks `jadx`/`jadx-gui` into `/usr/local/bin` (or `~/.local/bin`).
- **`pip install ... externally-managed-environment`** (Debian 12+/Kali) →
  BurpNinja retries with `--break-system-packages`. If that is blocked, use a
  virtualenv.
- **frida-server push fails** — device not rooted, or `/system` not
  remountable; see [`frida.md`](frida.md).
- **`adb: no permissions`** — add udev rules / add your user to `plugdev`, or
  `sudo adb ...`.

## Limitations

Requires root on the host **and** a rooted device/emulator. Package names
differ by distro; if `install_pkg` can't find a manager it warns and you
install manually.
