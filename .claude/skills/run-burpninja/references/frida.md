# Frida

**Purpose:** dynamic instrumentation. BurpNinja installs the Frida **client**
on the PC (via pip) and a matching **frida-server** on the device, then keeps
their versions in sync.

## Prerequisites

- PC: `frida` + `frida-tools` (pip). This container had client **17.17.0**.
- Device: rooted; `xz` (Linux/macOS) or 7-Zip (Windows) to extract the
  server binary.

## Detection

```bash
frida --version                                   # PC client (safe anywhere)
adb shell "/data/local/tmp/frida-server --version"  # device server
adb shell "/system/xbin/frida-server --version"     # alt location
```

`frida-ls-devices` / `frida-ps -U` **need a real TTY** — piped, they crash:

```
KeyError: '0 is not registered'   # asyncio, no controlling terminal
```

Run them under tmux (verified working — `driver.sh tui`):

```
Id        Type    Name             OS
--------  ------  ---------------  ------------
local     local   Local System     macOS 26.6.2
barebone  remote  GDB Remote Stub
socket    remote  Local Socket
```

(no `usb` row ⇒ no Android device attached.)

`driver.sh doctor` reports client version, device server version+location, and
whether they match.

## Setup / Usage — install frida-server (menu `[4]`, `install_frida_android`)

BurpNinja picks its method automatically:

- **Magisk detected** (`magisk -v` contains `MAGISK`) → installs the
  **MagiskFrida** module (auto-starts on boot) + **AlwaysTrustUserCerts**.
- **No Magisk** → `install_frida_manual`: reads `ro.product.cpu.abi`, maps to
  `x86_64|x86|arm64|arm`, downloads the matching
  `frida-server-<ver>-android-<arch>.xz` from GitHub, `xz -d`, pushes to
  `/data/local/tmp/frida-server`, `chmod 755`, and copies to `/system/xbin`.

Start it and inspect processes:

```bash
adb shell "su -c '/data/local/tmp/frida-server &'"   # background daemon
frida-ps -U | head        # enumerate processes (needs a TTY)
frida -U -f com.target.app -l bypass.js              # spawn + attach + script
```

## Version sync (menu `[5]`, `repair_frida_version`)

```
Installed client (frida --version)
        ↓
Installed server (frida-server --version)
        ↓
GitHub latest (Location redirect on /releases/latest)
        ↓
compare → upgrade whichever lags
```

BurpNinja upgrades the PC via `pip install frida frida-tools --upgrade
--break-system-packages` and reinstalls the device server. Client and server
**major versions must match** or `frida -U` errors with a version-mismatch
message.

## Verification

`frida --version` == device `frida-server --version`; `frida-ps -U` lists
processes; spawning the target with `-l bypass.js` prints the bypass banner.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `frida-ls-devices` asyncio `KeyError: '0 is not registered'` | Run under a TTY (`driver.sh tui`). |
| `unable to connect to remote frida-server` | Server not running / port-forward missing → `adb forward tcp:27042 tcp:27042`; start the server. |
| `frida.core.RPCException ... version` mismatch | Menu `[5]` to sync, or install the matching server. |
| `Failed to spawn: unable to find process with name` | Wrong package; `adb shell pm list packages | grep <name>`. |
| server won't stay up | `adb shell "pkill -9 frida-server"` then restart; try `frida-server -D`. |
| wrong arch downloaded | Re-check `ro.product.cpu.abi`; emulators are often `x86_64`. |

## Limitations

`frida -U` requires a USB/adb device and a running, version-matched server.
`bypass.js` uses `Java.perform` — it only works on Android/ART targets, not
local non-Java processes.
