# Example: Frida setup & SSL bypass

Goal: get client and server versions in sync, then inject `bypass.js` into an
authorized target.

## 1. Check versions

```bash
frida --version                    # PC client — this container: 17.17.0
.claude/skills/run-burpninja/driver.sh doctor   # shows client, device server, and match
```

Device server + match only appear when a device is attached; the doctor flags
`MISMATCH pc=X device=Y (menu [5])` when they differ.

## 2. Install / sync frida-server

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 4     # install (auto-detects ABI/Magisk)
# or, if versions drift:
.claude/skills/run-burpninja/driver.sh send 5     # Fix Frida Version Mismatch
.claude/skills/run-burpninja/driver.sh capture
```

The version-sync logic:

```
client (frida --version) vs server (frida-server --version) vs GitHub latest
        → upgrade whichever lags (pip for PC, re-push for device)
```

## 3. Sanity-check devices (needs a TTY)

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send "frida-ls-devices"
.claude/skills/run-burpninja/driver.sh capture
```

Verified under tmux with no phone attached (only local transports appear —
attach a device to get a `usb` row):

```
Id        Type    Name             OS
--------  ------  ---------------  ------------
local     local   Local System     macOS 26.6.2
barebone  remote  GDB Remote Stub
socket    remote  Local Socket
```

> Piping `frida-ls-devices` into a non-TTY crashes with
> `KeyError: '0 is not registered'` — always use a real terminal / `tui`.

## 4. Inject the SSL bypass (menu `[8]`)

```bash
.claude/skills/run-burpninja/driver.sh send 8
.claude/skills/run-burpninja/driver.sh send com.target.app    # AUTHORIZED app
.claude/skills/run-burpninja/driver.sh capture
```

`[8]` forwards ports 27042/27043, starts frida-server, and runs
`frida -U -f com.target.app -l bypass.js`. Success prints the bypass banner
and `[+] SSLContext.init hooked` / `[+] SSL Pinning Bypass Active`.

`bypass.js` was validated this session (`node --check bypass.js` → OK). What it
covers vs. what needs a custom script:
[`../references/ssl-pinning.md`](../references/ssl-pinning.md).

## 5. Verify

`[+]` hook lines in the Frida console **and** decrypted traffic in Burp. Hooks
but no traffic ⇒ proxy target wrong (`10.0.2.2` is emulator-only). Still
pinned ⇒ native/Flutter/custom pinning.

## Fallback without a custom script

```bash
objection -g com.target.app explore
# inside objection:
android sslpinning disable
```
