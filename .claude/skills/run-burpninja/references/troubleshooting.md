# Troubleshooting

Diagnose like a decision tree — **do not reinstall everything**:

```
Collect symptom → identify component → check environment (driver.sh doctor)
→ run one minimal diagnostic → read output → find root cause
→ apply the smallest fix → verify
```

Start every investigation with:

```bash
.claude/skills/run-burpninja/driver.sh doctor
.claude/skills/run-burpninja/driver.sh check
```

## BurpNinja launch / menu

| Symptom | Root cause | Fix |
|---|---|---|
| Prints only `[*] Running on macOS...` then exits | `clear` failed under empty/`dumb` TERM; `set -e` aborted | `TERM=xterm bash BurpNinja.sh` or `driver.sh menu` |
| `TERM environment variable not set.` | headless shell, no TERM | same as above |
| Script exits right after picking 2/4/5/6/7/8 | a `test_*` precondition `exit 1`'d (no device / Burp down / not root) | fix the failing precondition, relaunch |
| `[!] Invalid option` loops | non-numeric/blank input | send a valid menu number |
| Linux: `Run as root: sudo bash BurpNinja.sh` | not root on Linux | run with `sudo` (Linux only — never on macOS) |

## ADB

| Symptom | Fix |
|---|---|
| `error: no devices/emulators found` | connect/start device; check cable; `adb devices` |
| `unauthorized` | accept RSA prompt on device; `adb kill-server && adb start-server` |
| `offline` | `adb reconnect`; toggle USB debugging |
| `more than one device/emulator` | one target only, or `adb -s <serial>` |
| wrong Android architecture | re-read `getprop ro.product.cpu.abi`; emulators usually `x86_64` |

## Root

| Symptom | Fix |
|---|---|
| `su: Permission denied` / root check fails | grant ADB in Magisk/Superuser app; use a rooted device/emulator ([rootAVD](https://github.com/newbit1/rootAVD)) |
| `mount: read-only` on `/system` | try Magisk `AlwaysTrustUserCerts` module (BurpNinja installs it on Magisk) |

## Burp / certificate / HTTPS

| Symptom | Fix |
|---|---|
| `Burp proxy not detected` | start Burp; listener `127.0.0.1:8080`; physical device → bind all interfaces + host LAN IP |
| `Failed to download certificate` | Burp down or wrong `ip:port` |
| cert installed but app fails HTTPS | app pins → SSL bypass `[8]` or `objection ... android sslpinning disable` |
| HTTPS not intercepted at all | proxy not routed to Burp (device proxy / `10.0.2.2` emulator-only) |

## Frida

| Symptom | Fix |
|---|---|
| `frida-ls-devices` asyncio `KeyError: '0 is not registered'` | needs a TTY → `driver.sh tui` |
| version mismatch RPCException | menu `[5]` to sync client/server |
| `unable to connect to remote frida-server` | start server; `adb forward tcp:27042 tcp:27042` |
| `frida-server not found on device` | menu `[4]` first |
| server won't stay running | `adb shell pkill -9 frida-server`; restart; `frida-server -D` |
| script injection fails / `unable to find process` | wrong package name |

## SSL bypass

| Symptom | Fix |
|---|---|
| bypass hooks print but no traffic in Burp | wrong proxy target (`10.0.2.2` is AVD-only) — edit `bypass.js` or set device proxy |
| still pinned | native/Flutter/custom pinning → custom script ([`ssl-pinning.md`](ssl-pinning.md)) |
| app crashes after inject | root/Frida detection → attach mode / anti-detection script |

## RE tools

| Symptom | Fix |
|---|---|
| jadx OOM | `JAVA_OPTS="-Xmx4g" jadx ...` |
| apktool AAPT2/framework error | `apktool empty-framework-dir --force`; update apktool |
| scrcpy black/no device | check `adb devices`; DRM screens render black |
| objection can't attach | frida-server down / mismatched |

## PATH / permissions / OS

| Symptom | Fix |
|---|---|
| `command not found` for a tool | add to PATH; see [`macos.md`](macos.md)/[`linux.md`](linux.md)/[`windows.md`](windows.md) |
| `permission denied: ./BurpNinja.sh` | `chmod +x BurpNinja.sh` |
| `brew: command not found` (Apple Silicon) | `eval "$(/opt/homebrew/bin/brew shellenv)"` |
| `pip externally-managed-environment` | BurpNinja retries `--break-system-packages`; else use a venv |
| Windows garbled banner | `chcp 65001` / use Windows Terminal |

## Optional AI mode

BurpNinja's own AI mode (Anthropic key) is optional. If unavailable, ignore
it — nothing else depends on it. An **agent's own** AI-analysis capability may
interpret any of the outputs above, but it is not required.
