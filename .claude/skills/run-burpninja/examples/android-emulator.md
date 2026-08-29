# Example: Android emulator (AVD / Genymotion)

Emulators are the smoothest BurpNinja target: easy root and a fixed host
alias (`10.0.2.2`) that `bypass.js` already targets.

## 1. Root the emulator

- **Android Studio AVD:** use [rootAVD](https://github.com/newbit1/rootAVD)
  (a non–Google-Play system image). Many AVDs also accept `adb root`.
- **Genymotion:** rooted by default.

```bash
adb root                 # emulators: makes adbd run as root
adb shell id | grep uid=0
```

## 2. Confirm the environment

```bash
.claude/skills/run-burpninja/driver.sh doctor
adb shell getprop ro.product.cpu.abi     # typically x86_64 on AVD
```

## 3. Proxy routing — the emulator advantage

Inside the guest, the host machine is `10.0.2.2`. Burp on the host at
`127.0.0.1:8080` is therefore `10.0.2.2:8080` from the emulator — exactly what
`bypass.js` hard-codes, so no proxy editing is needed. (You can also set the
AVD Wi-Fi proxy to `10.0.2.2:8080`.)

## 4. Install cert + frida, then bypass

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 1     # full install
.claude/skills/run-burpninja/driver.sh capture
```

After `adb reboot`, for a pinned app:

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 8     # SSL bypass
.claude/skills/run-burpninja/driver.sh send com.target.app
.claude/skills/run-burpninja/driver.sh capture    # watch the [+] hook lines
```

## 5. Verify

Traffic from the app appears in Burp. The `frida-ls-devices` sanity check
(needs a TTY, so run it inside `tui`) should show a `usb`/emulator row in
addition to the `local` one seen with no device:

```
Id        Type    Name             OS
--------  ------  ---------------  ------------
local     local   Local System     macOS 26.6.2
...
```

## Gotchas

- x86_64 AVDs pull the `x86_64` frida-server — BurpNinja handles the mapping.
- If the app detects the emulator and refuses to run, use a physical device
  ([`physical-device.md`](physical-device.md)) or an anti-detection script.
