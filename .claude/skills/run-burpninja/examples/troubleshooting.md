# Example: "BurpNinja isn't working"

Do **not** reinstall everything. Work the decision tree. These are real
sessions from building this skill.

```
Collect symptom → identify component → driver.sh doctor → one diagnostic
→ read output → root cause → smallest fix → verify
```

## Case A — "It launches then immediately quits, no menu"

Symptom seen:

```
[*] Running on macOS (Apple). Standard permissions.
TERM environment variable not set.
```

**Component:** the TUI banner. **Cause:** `show_banner` calls `clear`; with an
empty/`dumb` TERM `clear` returns nonzero and `set -e` aborts the script.
**Fix:**

```bash
TERM=xterm bash BurpNinja.sh
# or just use the driver, which forces TERM=xterm:
.claude/skills/run-burpninja/driver.sh menu 3
```

Verify: the banner + menu render.

## Case B — "It quits the moment I pick Device Info / SSL Bypass"

Symptom seen (option 7, no device):

```
  ┌─ ADB Connection ────────────────────────────────────
[!] ADB device not ready: error: no devices/emulators found
```

…and the whole program ends. **Cause:** `test_adb` calls `exit 1` on failure,
which kills the script (not just the menu action). Same for `test_burpsuite`,
`test_internet`, and the root check. **Fix:** satisfy the precondition, then
relaunch.

```bash
.claude/skills/run-burpninja/driver.sh doctor    # find the red line
adb devices -l                                    # fix the device, then retry
```

## Case C — "frida-ls-devices throws a Python traceback"

Symptom seen (piped, no TTY):

```
KeyError: '0 is not registered'
```

**Cause:** frida's CLI needs a controlling terminal. **Fix:** run it under a
real TTY / tmux — verified working:

```bash
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send "frida-ls-devices"
.claude/skills/run-burpninja/driver.sh capture
```

## Case D — "AI mode won't turn on"

Symptom seen (bad key):

```
  ┌─ Enable AI Mode ────────────────────────────────────
[!] Invalid key format. Should start with sk-ant-
```

**Cause:** `enable_ai` requires a key matching `^sk-ant-` and validates it
with a live ping. **Fix:** supply a real Anthropic key — or skip AI mode
entirely; nothing else depends on it.

## Case E — "Traffic isn't showing in Burp after the bypass"

**Component:** proxy routing, not pinning. **Cause:** `bypass.js` routes to
`10.0.2.2:8080` (emulator host alias); on a physical device that IP is wrong.
**Fix:** set the device proxy to the host LAN IP, or edit `bypass.js`. See
[`physical-device.md`](physical-device.md) and
[`../references/ssl-pinning.md`](../references/ssl-pinning.md).

## When you lack terminal access

Give the user the single diagnostic (`driver.sh doctor`, or the one command
for the failing component) and ask them to paste the output. Interpret, then
prescribe the smallest fix. If you have an AI-analysis capability, use it to
read the error — but it is never required.
