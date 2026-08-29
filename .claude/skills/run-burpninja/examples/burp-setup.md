# Example: Burp Suite setup & CA install

Goal: verify the proxy config, then install the Burp CA into the device's
**system** trust store. **Verify before changing** — check what's there first.

## 1. Is Burp reachable?

```bash
.claude/skills/run-burpninja/driver.sh doctor    # [ Burp proxy ] block
```

With Burp not running this container reported:

```
[ Burp proxy (127.0.0.1:8080) ]
  reachable        no (start Burp; listener on 127.0.0.1:8080)
```

Start Burp, set Proxy → Options listener to `127.0.0.1:8080` (or all
interfaces for a LAN device), and re-run — expect `reachable: yes`.

To point BurpNinja at a non-default proxy, export it before launching:

```bash
BURP_IP=192.168.1.10:8080 .claude/skills/run-burpninja/driver.sh doctor
```

(BurpNinja itself also prompts for a custom `ip:port` when the default fails.)

## 2. Is a cert already installed? (verify before overwriting)

```bash
adb shell "su -c 'ls /system/etc/security/cacerts/'" | grep 9a5ba575.0
```

If present, BurpNinja's `[2]` prompts before replacing.

## 3. Install the cert (menu `[2]`)

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 2
.claude/skills/run-burpninja/driver.sh capture
```

`[2]` runs internet → adb/root → Burp checks → `install_cert`
(download DER → PEM → `subject_hash_old` → push → place in the system store →
chmod/chown). Expected: `[+] Certificate installed. Run: adb reboot`.

```bash
adb reboot
```

The exact manual equivalent is in
[`../references/burp-suite.md`](../references/burp-suite.md) and
[`../references/commands.md`](../references/commands.md).

## 4. Verify interception

Browse an HTTPS site on the device → it appears in Burp's HTTP history. Apps
with pinning still need the SSL bypass ([`frida-setup.md`](frida-setup.md)).

## Gotchas

- `openssl` missing → `[2]` auto-installs it; if that fails, install manually.
- `/system` read-only → Magisk `AlwaysTrustUserCerts` module (BurpNinja
  installs it on Magisk devices) sidesteps the remount.
- Reboot is required for the system store to pick up the new cert.
