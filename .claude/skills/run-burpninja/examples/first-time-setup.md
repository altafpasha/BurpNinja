# Example: first-time setup

Goal: go from a clean machine + a rooted Android emulator to intercepting
HTTPS in Burp. This is the "Set up BurpNinja" interaction protocol.

## Agent protocol

1. Inspect the environment. 2. Determine OS. 3. Check dependencies.
4. Check Android connectivity. 5. Determine device architecture.
6. Determine root status. 7. Configure missing components. 8. Verify each
stage. 9. Report final status.

## Step 0 — read the environment (read-only)

```bash
.claude/skills/run-burpninja/driver.sh doctor
```

Confirm: OS/arch; adb present; a device in the `[ Android device ]` block;
root line; Burp reachable. Fix red lines before continuing.

> If terminal execution isn't available, give the user `driver.sh doctor` and
> ask them to paste the output.

## Step 1 — install PC tools (menu `[3]`)

```bash
.claude/skills/run-burpninja/driver.sh menu 3
```

Expected (all-present case seen on this container):

```
[+] Internet connection OK
[+] jadx already installed
[+] apktool already installed
[+] scrcpy already installed
[+] Frida and Objection already installed
```

## Step 2 — connect a rooted emulator

Start an AVD/Genymotion instance, then:

```bash
adb devices -l
adb get-state                         # device
adb shell id | grep uid=0             # or: adb shell "su -c id"
adb shell getprop ro.product.cpu.abi  # e.g. x86_64
```

Not rooted? See [`../references/android-setup.md`](../references/android-setup.md).

## Step 3 — start Burp

Launch Burp; Proxy listener on `127.0.0.1:8080`. Verify:

```bash
.claude/skills/run-burpninja/driver.sh doctor    # Burp block → reachable: yes
```

## Step 4 — full install (menu `[1]`)

With device + root + Burp confirmed, run BurpNinja live and pick `1`:

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 1
# watch progress:
.claude/skills/run-burpninja/driver.sh capture
```

`[1]` runs: internet → Burp → adb/root → PC tools → Android apps →
frida-server → Burp cert. Ends with `All done. Run: adb reboot`.

```bash
adb reboot
.claude/skills/run-burpninja/driver.sh kill
```

## Step 5 — verify each stage

```bash
.claude/skills/run-burpninja/driver.sh doctor
# frida client == device server? cert present? Then browse HTTPS on the
# device and watch Burp's HTTP history.
```

## Step 6 — report status

Summarize per stage: OS ✓, tools ✓, device+root ✓, ABI, Burp ✓, cert ✓,
frida in sync ✓. Note anything skipped and why. For pinned apps continue to
[`frida-setup.md`](frida-setup.md) → SSL bypass.
