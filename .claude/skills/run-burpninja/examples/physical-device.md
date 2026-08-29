# Example: physical device

A real (rooted) phone differs from an emulator in two ways: root comes from
Magisk/KernelSU, and **proxy routing is not `10.0.2.2`** — you must use the
host's LAN IP.

## 1. Prep the device

- Enable Developer Options → USB Debugging.
- Rooted via Magisk/KernelSU.
- Connect via USB (accept the RSA "Allow USB debugging?" prompt). macOS may
  show "Allow accessory to connect?" — click **Allow**.

```bash
adb devices -l                 # should be "device", not "unauthorized"
adb shell "su -c id" | grep uid=0
adb shell getprop ro.product.cpu.abi    # often arm64-v8a → frida arm64
```

## 2. Environment check

```bash
.claude/skills/run-burpninja/driver.sh doctor
```

If root shows "NOT rooted", open the Magisk app and grant shell root, then
re-run.

## 3. Burp on a LAN IP (key difference)

Burp → Proxy → listener bound to **all interfaces** on `:8080`. Find the
host IP (`ipconfig getifaddr en0` on macOS / `ip addr` on Linux). On the
device set the Wi-Fi proxy to `HOST_LAN_IP:8080`, or use the ProxyToggle /
ProxyDroid apps BurpNinja installs.

## 4. Install cert + frida-server

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 2     # Burp cert → Android
.claude/skills/run-burpninja/driver.sh send 4     # frida-server (arm64)
.claude/skills/run-burpninja/driver.sh capture
```

Magisk devices get the MagiskFrida + AlwaysTrustUserCerts modules instead of a
manual binary. Reboot after cert install: `adb reboot`.

## 5. SSL bypass — edit the proxy target

`bypass.js` hard-codes `10.0.2.2:8080`, which is wrong for a physical device.
Either:

- set a **device proxy** to `HOST_LAN_IP:8080` (then the TrustManager hooks
  alone are enough), **or**
- edit `bypass.js`, replacing `10.0.2.2` with your host LAN IP, before
  running `[8]`.

```bash
.claude/skills/run-burpninja/driver.sh send 8
.claude/skills/run-burpninja/driver.sh send com.target.app
.claude/skills/run-burpninja/driver.sh capture
```

## 6. Verify

App HTTPS shows in Burp. If hooks print but no traffic arrives, the proxy
target is still wrong (recheck step 3/5) — see
[`../references/ssl-pinning.md`](../references/ssl-pinning.md).

## Gotchas

- Physical arm64 devices need the `arm64` frida-server — BurpNinja maps this
  from `ro.product.cpu.abi`.
- Some apps run anti-root/anti-Frida checks on real hardware too; expect to
  add an anti-detection script.
