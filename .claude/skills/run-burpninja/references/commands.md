# Command cheat sheet (per OS)

Commands are grouped by where they run. **Do not assume a Linux command works
on macOS/Windows.** Prefer commands already used by BurpNinja. Anything under
`frida -U`/`frida-ls-devices` needs a real TTY (use `driver.sh tui`).

## Driver (macOS / Linux) — the agent path

```bash
.claude/skills/run-burpninja/driver.sh doctor      # read-only env report
.claude/skills/run-burpninja/driver.sh check       # bash -n + node --check
.claude/skills/run-burpninja/driver.sh menu 3      # drive menu headlessly
.claude/skills/run-burpninja/driver.sh tui         # launch live in tmux
.claude/skills/run-burpninja/driver.sh send 3      # press a key live
.claude/skills/run-burpninja/driver.sh capture     # snapshot the pane
.claude/skills/run-burpninja/driver.sh kill        # end live session
```

## Launch BurpNinja

```bash
# macOS (standard user, TERM must be set):
chmod +x BurpNinja.sh && TERM=xterm ./BurpNinja.sh

# Linux (root):
sudo -E TERM=xterm bash BurpNinja.sh
```

```powershell
# Windows PowerShell (as Administrator):
powershell -ExecutionPolicy Bypass -File ".\BurpNinja.ps1"
```

## Base deps

```bash
# macOS
brew install android-platform-tools openssl python xz

# Linux — Debian/Ubuntu/Kali
sudo apt install adb openssl python3-pip xz-utils curl unzip
# Linux — Arch
sudo pacman -S android-tools openssl python-pip xz curl unzip
# Linux — Fedora
sudo dnf install android-tools openssl python3-pip xz curl unzip
```

```powershell
# Windows
scoop bucket add extras; scoop install jadx apktool scrcpy openssl
python -m pip install frida frida-tools objection
```

```bash
# frida + objection (macOS/Linux)
pip3 install frida frida-tools objection --break-system-packages
```

## ADB (all hosts)

```bash
adb devices -l
adb get-state
adb shell getprop ro.product.cpu.abi
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb forward tcp:27042 tcp:27042
adb forward tcp:27043 tcp:27043
adb reboot
```

## Android shell (over `adb shell`, root)

```bash
su -c 'id'
su -c 'mount -o rw,remount /system'
su -c 'ls /system/etc/security/cacerts/'
"/data/local/tmp/frida-server --version"
"nohup /data/local/tmp/frida-server >/dev/null 2>&1 &"
"pkill -9 frida-server"
"pm list packages | grep target"
```

## Burp cert (macOS / Linux)

```bash
curl http://127.0.0.1:8080/cert -o cacert.der
openssl x509 -inform DER -in cacert.der -out cacert.pem
HASH=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1)
cp cacert.pem "${HASH}.0"
adb push "${HASH}.0" /sdcard/
adb shell "su -c 'mv /sdcard/${HASH}.0 /system/etc/security/cacerts/'"
adb shell "su -c 'chmod 644 /system/etc/security/cacerts/${HASH}.0'"
adb reboot
```

## Frida / bypass

```bash
frida --version
frida-ls-devices                       # TTY required
frida-ps -U                            # TTY required
frida -U -f com.target.app -l bypass.js         # .sh edition
frida -H 127.0.0.1:27042 -f com.target.app -l bypass.js   # .ps1 edition
objection -g com.target.app explore    # then: android sslpinning disable
```

## RE tools

```bash
jadx -d out target.apk
jadx-gui target.apk
apktool d target.apk -o target_src
scrcpy
```
