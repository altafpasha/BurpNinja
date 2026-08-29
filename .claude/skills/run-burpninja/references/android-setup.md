# Android setup

**Purpose:** prepare an Android device or emulator so BurpNinja can install
the Burp CA, deploy frida-server, and intercept traffic.

## The full workflow (each stage links to detail)

```
Environment ─ driver.sh doctor / references/installation.md
   ↓
ADB ─────────── references/adb.md
   ↓
Device/Emulator ─ this file (below)
   ↓
Root verification ─ two-tier check (below)
   ↓
Architecture detection ─ getprop ro.product.cpu.abi
   ↓
Burp configuration ─ references/burp-suite.md
   ↓
CA certificate ─ references/burp-suite.md (install_cert)
   ↓
Frida ───────── references/frida.md (PC client)
   ↓
Frida server ── references/frida.md (device)
   ↓
Target application ─ package name (pm list packages)
   ↓
SSL interception ─ references/ssl-pinning.md
   ↓
Testing / Diagnostics ─ references/troubleshooting.md
```

## Prerequisites

- USB debugging enabled (Settings → Developer Options → USB Debugging).
- A **rooted** device or emulator (system-cert install and frida-server need
  root). Root options from the repo: [rootAVD](https://github.com/newbit1/rootAVD)
  for Android Studio AVD, built-in root for Genymotion, BlueStacks settings.
- Exactly **one** device/emulator connected (BurpNinja assumes a single
  target).

## Detection

```bash
adb devices -l
adb get-state          # expect: device
adb shell getprop ro.product.cpu.abi     # ABI → frida arch
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
```

Or all at once, read-only:

```bash
.claude/skills/run-burpninja/driver.sh doctor   # [ Android device ] block
```

With no device this container reported:

```
[ Android device ]
  adb state        error: no devices/emulators found
```

## Root verification (BurpNinja's two-tier logic)

```bash
adb shell id | grep uid=0          # Tier 1: adb itself is root (emulators)
adb shell "su -c id" | grep uid=0  # Tier 2: su available (Magisk/KernelSU)
```

`adb_root_exec` in `BurpNinja.sh` wraps commands to run whichever way works
(`direct` / `su 0 sh -c` / `su -c`). Expected success: a line containing
`uid=0(root)`. Failure ⇒ device is not rooted; the cert/frida steps cannot
proceed.

## Setup / Usage

Once ADB + root + ABI are confirmed, run BurpNinja `[1] Full Install` (or the
individual options `2/4/6`). Device info at any time:

```bash
.claude/skills/run-burpninja/driver.sh menu 7   # needs a device; else exits
```

## Verification

`adb get-state` → `device`; root check → `uid=0`; ABI known; Burp reachable.
Then proceed to [`burp-suite.md`](burp-suite.md) and [`frida.md`](frida.md).

## Troubleshooting

Device not found / unauthorized / emulator missing → [`adb.md`](adb.md).
Root denied → open the Magisk/Superuser app and grant ADB the request.

## Limitations

Unrooted production devices cannot receive a system-store cert or
frida-server via this workflow. Emulators are the smoothest path.
