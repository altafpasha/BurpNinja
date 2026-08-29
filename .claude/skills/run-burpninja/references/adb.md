# ADB

**Purpose:** the transport BurpNinja uses for every device operation
(cert push, frida-server deploy, app install, `getprop`, port forwarding).

**Prerequisites:** `adb` on PATH; USB debugging on; device authorized.

## Detection

```bash
adb version
adb devices -l          # lists devices; "unauthorized" / "offline" are states
adb get-state           # "device" when ready
```

`driver.sh doctor` runs `adb get-state` and, when a device is present, prints
model/android/api/abi/root/frida-server. Verified with no device attached:

```
adb state        error: no devices/emulators found
```

## Setup / Usage

```bash
# Wireless ADB (BurpNinja also installs the "ADB WiFi" helper app):
adb tcpip 5555
adb connect <device-ip>:5555

# Port forwarding used by the SSL-bypass flow:
adb forward tcp:27042 tcp:27042
adb forward tcp:27043 tcp:27043

# Root the adbd on emulators:
adb root
```

## Verification

`adb get-state` → `device`. `adb shell echo ok` → `ok`.

## Troubleshooting (symptom → fix)

| Symptom | Fix |
|---|---|
| `error: no devices/emulators found` | Plug in / start emulator; check cable; `adb devices`. |
| `unauthorized` | Accept the "Allow USB debugging?" RSA prompt on the device; `adb kill-server && adb start-server`. |
| `offline` | Reconnect; `adb reconnect`; toggle USB debugging. |
| `more than one device/emulator` | BurpNinja assumes one target — disconnect extras or use `adb -s <serial>`. |
| macOS "Allow accessory to connect?" | Click **Allow**. |
| `adb: no permissions` (Linux) | udev rules / `plugdev` group, or `sudo adb`. |
| `adb: command not found` | Install platform-tools; add to PATH (see OS references). |

## Limitations

BurpNinja does not disambiguate multiple devices; connect one at a time. Some
of BurpNinja's device commands assume root via `adb_root_exec`.
