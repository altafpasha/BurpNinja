# Reverse engineering tools

**Purpose:** the static/dynamic RE tools BurpNinja installs (menu `[3]`) and
which to reach for. BurpNinja installs them; it does not wrap them — you use
each directly.

## Tool → task map

| Tool | Use it for | Verified here |
|---|---|---|
| **JADX** | Decompile APK/DEX to readable Java; find endpoints, keys, pinning code, package names. GUI: `jadx-gui`. | jadx 1.5.6 |
| **Apktool** | Decode resources & smali; read `AndroidManifest.xml` and `network_security_config.xml`; repackage. | apktool 3.0.3 |
| **Scrcpy** | Mirror/control the device screen from the PC while testing. | scrcpy 4.1 |
| **Objection** | Runtime exploration on top of Frida — quick `android sslpinning disable`, class/method enumeration, heap search, no custom script needed. | objection 1.12.5 |
| **Frida** | Custom instrumentation & the SSL bypass (`bypass.js`). | frida 17.17.0 |
| **ADB** | Transport for everything device-side. | 1.0.41 |

## Which one when

- **"What does this app talk to / is it pinned?"** → JADX (read the code) or
  Apktool (read `network_security_config.xml`).
- **"Turn off pinning fast."** → Objection `android sslpinning disable`, or
  BurpNinja `[8]` (`bypass.js`) for the scripted path.
- **"I need to hook a specific method."** → Frida with a custom script.
- **"Watch the app while I test."** → Scrcpy.

## Detection

```bash
.claude/skills/run-burpninja/driver.sh doctor   # reports each tool's version
jadx --version && apktool --version && scrcpy --version && objection version
```

## Usage examples

```bash
jadx -d out_dir target.apk               # decompile to ./out_dir
jadx-gui target.apk                       # interactive
apktool d target.apk -o target_src        # decode
scrcpy                                     # mirror the connected device
objection -g com.target.app explore       # runtime REPL
#   inside objection:  android sslpinning disable
frida -U -f com.target.app -l bypass.js   # scripted instrumentation
```

## Verification

Each tool prints a version and produces its output (decompiled tree, mirror
window, objection REPL prompt).

## Troubleshooting

- **jadx OOM on large APKs** → raise heap: `JAVA_OPTS="-Xmx4g" jadx ...`.
- **Apktool framework errors** → `apktool empty-framework-dir --force` then
  retry; update apktool for new AAPT2 resources.
- **Scrcpy black screen / no device** → check `adb devices`; some DRM screens
  render black.
- **Objection can't attach** → frida-server not running or version mismatch
  ([`frida.md`](frida.md)).

## Limitations

BurpNinja installs these but leaves their use to you. Decompilation of
heavily obfuscated or natively-implemented apps has the usual RE limits.
