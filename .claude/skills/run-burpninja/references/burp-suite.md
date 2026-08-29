# Burp Suite

**Purpose:** point the Android device's HTTPS traffic at Burp and make the
device trust Burp's CA at the **system** level so interception works even for
apps that only trust the system store.

> **Verify current config before changing anything.** Run `driver.sh doctor`
> (Burp-proxy block) and check the existing cert on-device before overwriting.

## Prerequisites

- Burp Suite running with a Proxy listener. BurpNinja defaults to
  `127.0.0.1:8080` (`BURP_IP`); it prompts for a custom `ip:port` if the
  default is unreachable.
- Device reachable over adb, rooted, openssl available (menu `[2]`
  auto-installs openssl if missing).

## Detection

```bash
# Is Burp reachable? (BurpNinja's test_burpsuite logic)
curl -s --max-time 5 http://127.0.0.1:8080/ | grep -i "burp\|proxy"

# Is a Burp cert already on the device?
adb shell "su -c 'ls /system/etc/security/cacerts/'" | grep 9a5ba575.0
```

`driver.sh doctor` reports Burp reachability. With Burp down this container
showed:

```
[ Burp proxy (127.0.0.1:8080) ]
  reachable        no (start Burp; listener on 127.0.0.1:8080)
```

## Setup / Usage — CA cert install (menu `[2]`, `install_cert`)

BurpNinja automates exactly this sequence (you can run it manually too):

```bash
# 1. Download DER cert from Burp
curl http://127.0.0.1:8080/cert -o cacert.der
# 2. DER → PEM
openssl x509 -inform DER -in cacert.der -out cacert.pem
# 3. Android system store uses the old subject hash as the filename
HASH=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1)
cp cacert.pem "${HASH}.0"
# 4. Push + place into the system store (root)
adb push "${HASH}.0" /sdcard/
adb shell "su -c 'mount -o rw,remount /system'"
adb shell "su -c 'mv /sdcard/${HASH}.0 /system/etc/security/cacerts/'"
adb shell "su -c 'chmod 644 /system/etc/security/cacerts/${HASH}.0'"
adb shell "su -c 'chown root:root /system/etc/security/cacerts/${HASH}.0'"
# 5. Reboot to load it
adb reboot
```

Expected: `[+] Certificate installed. Run: adb reboot`. If a cert named
`9a5ba575.0` already exists, BurpNinja prompts before replacing.

### Routing device traffic to Burp

- **Emulator (AVD):** Burp is reachable at `10.0.2.2:8080` from inside the
  guest — this is what `bypass.js` hard-codes.
- **Physical device / Genymotion:** set the Wi-Fi proxy (or use the
  ProxyToggle / ProxyDroid helper apps BurpNinja installs) to the **host's LAN
  IP**:`8080`, and set Burp's listener to "all interfaces".

## Verification

After reboot, browse HTTPS from the device — requests appear in Burp's HTTP
history. For pinned apps you still need the SSL bypass
([`ssl-pinning.md`](ssl-pinning.md)).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Burp proxy not detected` | Start Burp; Proxy → Options → listener `127.0.0.1:8080`; for LAN devices bind all interfaces + use host IP. |
| `Failed to download certificate` | Burp not running or wrong `ip:port`; re-check listener. |
| Cert installed but app still fails | App uses pinning → use the SSL bypass, or `objection ... android sslpinning disable`. |
| `mount: read-only` | `/system` not remountable; some devices need `magisk resetprop`/overlay. |

## Limitations

System-store install needs root and a writable `/system` (or a Magisk
"AlwaysTrustUserCerts" module — BurpNinja installs that on Magisk devices).
Android 14+ moved system certs to an APEX/updatable store on some builds;
the classic `/system/etc/security/cacerts` path may not apply everywhere.
