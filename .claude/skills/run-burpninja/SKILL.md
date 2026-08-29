---
name: run-burpninja
description: Run, launch, drive, set up, screenshot, or troubleshoot BurpNinja — the Android pentest lab-setup toolkit (Burp CA cert, Frida server, SSL-pinning bypass, ADB, JADX/Apktool/Scrcpy/Objection). Use when asked to run BurpNinja, set up the Android testing environment, diagnose why BurpNinja isn't working, or drive its menu.
version: 1.0.0
license: MIT
platforms: [macOS, Linux, Windows]
---

# BurpNinja

BurpNinja is an **interactive terminal menu** (`BurpNinja.sh` for macOS/Linux,
`BurpNinja.ps1` for Windows) that automates Android app-security lab setup:
installs the Burp Suite CA into the Android system trust store, deploys a
Frida server matched to the device ABI, injects a one-click SSL-pinning
bypass (`bypass.js`), installs PC tools (JADX, Apktool, Scrcpy, Frida,
Objection) and proxy helper apps. There is an optional Claude-API "AI mode"
that diagnoses errors — it is not required for anything.

Because it is a TUI, a markdown file cannot "click" its menu. The harness
that drives it is **[`driver.sh`](driver.sh)**, committed next to this skill
(invoke it as `.claude/skills/run-burpninja/driver.sh` from the repo root).
Read this section first.

> **Paths below are relative to the repo root** (the directory containing
> `BurpNinja.sh`). The driver resolves its own paths, so you can call it
> from anywhere.

## Universal / agent-agnostic

This skill is plain Markdown + a portable bash driver. It requires **no**
vendor API (OpenAI, Anthropic, Gemini, Copilot, Cursor, MCP, …). Any agent
that can read files and — optionally — run shell commands can use it. When a
capability is missing, hand the command to the user and ask for the output.
See [`references/architecture.md`](references/architecture.md) for the
required-vs-optional capability model and [`adapters/`](adapters/) for
per-agent loading notes.

## Run (agent path) — use the driver

`driver.sh` gives you a programmatic handle on BurpNinja plus a
non-destructive environment doctor. Every command here was run in this
container against this repo.

```bash
# 1. First thing, always: read-only environment report.
#    Mirrors BurpNinja's own detection (OS, arch, tools, adb, root,
#    frida client/server sync, Burp proxy). Safe to run repeatedly.
.claude/skills/run-burpninja/driver.sh doctor

# 2. Static sanity check of the scripts.
.claude/skills/run-burpninja/driver.sh check

# 3. Drive the menu headlessly: pass menu numbers as args. The driver
#    appends the "press Enter" pauses and a final 0 to exit for you.
#    Example: option 3 = PC Tools (internet check + tool detection).
.claude/skills/run-burpninja/driver.sh menu 3
```

For live, keystroke-level interaction (and a TUI "screenshot"):

```bash
# Launch BurpNinja live inside tmux and print the opening screen.
.claude/skills/run-burpninja/driver.sh tui

# Press a key live (sends "3" + Enter, then prints the pane).
.claude/skills/run-burpninja/driver.sh send 3

# Snapshot the current screen at any time.
.claude/skills/run-burpninja/driver.sh capture

# End the live session.
.claude/skills/run-burpninja/driver.sh kill
```

Menu numbers (verified against `BurpNinja.sh`): `1` Full Install · `2` Burp
cert → Android · `3` PC tools · `4` Android Frida server · `5` Fix Frida
version mismatch · `6` Android apps · `7` Device info · `8` **Frida SSL
bypass** · `9` Enable AI (or AI session review when enabled) · `0` Exit.

Options `2,4,5,6,7,8` call `test_adb` / `test_burpsuite`, which **`exit 1`
on failure** — see Gotchas. Without a connected, rooted Android device those
options terminate the whole script; `3` and `9` (invalid-key path) are the
device-free ones you can drive here.

## Native CLI subcommands (BurpNinja.sh ≥ v2.2.0)

As of v2.2.0 `BurpNinja.sh` also accepts non-interactive subcommands — no args
still opens the menu (fully backward compatible). These are read-only/safe and
verified this session:

```bash
./BurpNinja.sh doctor          # read-only health check (System/Tools/Android/Burp/Frida)
./BurpNinja.sh status          # compact readiness dashboard
./BurpNinja.sh setup --dry-run # preview the full-install plan, change nothing
./BurpNinja.sh --help          # usage, commands, examples, troubleshooting
./BurpNinja.sh version         # -> BurpNinja v2.2.0
```

Global flags: `--dry-run` (no changes), `--safe` (diagnostics only), `--verbose`,
`--debug`. `doctor` exits non-zero if any check FAILs (CI-friendly). The
skill's `driver.sh doctor` and this native `doctor` overlap; the **driver**
adds live TUI driving (`tui`/`send`/`capture`) and headless menu feeding
(`menu <keys>`), and works even when run from outside the repo — so it stays
the primary agent path. Use the native subcommands when driving BurpNinja as
an end-user CLI.

## Run (human path)

```bash
chmod +x BurpNinja.sh
./BurpNinja.sh doctor   # NEW: quick readiness check, no menu
./BurpNinja.sh          # macOS: standard user, do NOT use sudo — opens the menu
sudo bash BurpNinja.sh  # Linux: run as root
```

Windows: `powershell -ExecutionPolicy Bypass -File ".\BurpNinja.ps1"` (as
Administrator). The human path opens the menu and blocks on `read` — useless
for an agent driving it headlessly; use `driver.sh menu` / `tui` instead.

## The core workflow

```
doctor → adb device → root → detect ABI → Burp proxy → CA cert
       → frida-server (match client) → target app → SSL bypass → intercept
```

Each stage — prerequisites, exact commands, expected output, failures — is in
the references. Start points:

- **First-time setup:** [`examples/first-time-setup.md`](examples/first-time-setup.md)
- **Emulator vs. physical device:** [`examples/android-emulator.md`](examples/android-emulator.md), [`examples/physical-device.md`](examples/physical-device.md)
- **Burp / Frida / SSL bypass:** [`examples/burp-setup.md`](examples/burp-setup.md), [`examples/frida-setup.md`](examples/frida-setup.md), [`references/ssl-pinning.md`](references/ssl-pinning.md)
- **When something breaks:** [`examples/troubleshooting.md`](examples/troubleshooting.md), [`references/troubleshooting.md`](references/troubleshooting.md)

## Prerequisites for the driver

The driver needs only `bash`. `doctor` degrades gracefully when a tool is
absent (it reports MISSING). Optional, for extra features:

- `tmux` — for `tui`/`send`/`capture` live driving.
- `node` — for the `bypass.js` `node --check` in `check`.
- `adb` — for the device section of `doctor`.

On this container all were present. To install what BurpNinja *itself* needs
per OS, see [`references/installation.md`](references/installation.md),
[`references/macos.md`](references/macos.md),
[`references/linux.md`](references/linux.md),
[`references/windows.md`](references/windows.md).

## Gotchas (verified this session)

- **`clear` + `set -euo pipefail` kills the banner under a bad TERM.** With
  `TERM` empty or `dumb`, the first `clear` in `show_banner` returns nonzero
  and `set -e` aborts before the menu even draws — you see only
  `[*] Running on macOS ...` and nothing else. The driver forces `TERM=xterm`
  for headless runs; if you invoke `BurpNinja.sh` directly, prefix it:
  `TERM=xterm bash BurpNinja.sh`.
- **`test_adb` / `test_internet` / root-check `exit` the whole program, not
  just the action.** They call `exit 1` on failure. Selecting option `7` with
  no device prints `[!] ADB device not ready: error: no devices/emulators
  found` and the script ends — it does **not** loop back to the menu. Fix the
  precondition, then relaunch. (As of v2.2.0, **`test_burpsuite` is the
  exception**: when Burp is unreachable it shows a guided recovery menu —
  Retry / different address / try-to-launch / Skip / Cancel — instead of
  hard-exiting; non-interactive/`--dry-run` runs skip the prompt and continue.)
- **Fixed in v2.2.0 — `ai_analyze` used to abort the script when AI was off.**
  Its old `$AI_ENABLED || return` returned status 1 when AI was disabled;
  because callers invoke it as a bare statement under `set -e`, the script
  died right after *any* error that called it (e.g. `setup` printed
  `[!] Burp Suite not detected` and immediately dropped back to the shell,
  never showing a prompt). Now it `return 0`s, so recovery prompts run.
- **`frida-ls-devices` / `frida -U` need a real TTY.** Piped into a
  non-tty they crash with a Python `asyncio ... KeyError: '0 is not
  registered'` traceback. Run them under `tmux` (as the driver's `tui` mode
  does) or a real terminal. `frida --version` is safe anywhere.
- **macOS: no `sudo`.** BurpNinja detects Darwin and runs as standard user
  so Homebrew/pip stay in user space; `sudo` breaks that. Linux is the
  opposite — it `exit 1`s if not root.
- **`bash 3.2` on stock macOS.** The shebang is `#!/usr/bin/env bash`; macOS
  ships bash 3.2. `bash -n BurpNinja.sh` passes there, and the driver avoids
  bash-4-only syntax.
- **SSL bypass hard-codes `10.0.2.2:8080`** (the AVD host alias) in
  `bypass.js`'s proxy hooks. That is emulator-specific — physical devices
  need the host's LAN IP. See [`references/ssl-pinning.md`](references/ssl-pinning.md).
- **AI mode is optional and never blocks.** With no key, error handlers are
  silent no-ops; `enable_ai` rejects anything not matching `^sk-ant-`.

## Troubleshooting (symptom → fix, all seen this session)

| Symptom | Fix |
|---|---|
| Only `[*] Running on macOS...` prints, no menu | `TERM` is empty/`dumb`; run `TERM=xterm bash BurpNinja.sh` or use `driver.sh menu`. |
| `TERM environment variable not set.` then exit | Same as above. |
| Script exits right after choosing 4/5/6/7 | A `test_adb`/`test_internet` precondition failed (no device / offline / not root). Run `driver.sh doctor` or `./BurpNinja.sh doctor`, fix the red line, retry. |
| `setup`/`[2]` prints `[!] Burp Suite not detected` then a recovery menu | Burp is down; choose Retry after starting it, enter a different `ip:port`, let it try to launch Burp, or Skip. (Pre-v2.2.0 this silently exited — now fixed.) |
| `frida-ls-devices` asyncio `KeyError: '0 is not registered'` | Needs a TTY — run under `driver.sh tui` or a real terminal. |
| `[!] Invalid key format. Should start with sk-ant-` | AI-key validation; supply a real `sk-ant-…` key or skip AI mode. |
| `adb get-state` → `error: no devices/emulators found` | Connect/authorize the device or start the emulator; see [`references/adb.md`](references/adb.md). |

## Safety

Authorized testing only — apps you own or have written permission to test.
Installing the Burp CA into the system store and disabling SSL pinning
weaken the device's security posture: do it only on dedicated test
devices/emulators. Before any device-modifying action (cert install,
`/system` remount, frida-server push) confirm the target and prefer
reversible steps. Never print or commit API keys, certs, or device secrets.
Full model: [`references/security.md`](references/security.md).

## Reference index

- [`references/architecture.md`](references/architecture.md) — components, capability model, version-awareness
- [`references/installation.md`](references/installation.md) · [`macos.md`](references/macos.md) · [`linux.md`](references/linux.md) · [`windows.md`](references/windows.md)
- [`references/android-setup.md`](references/android-setup.md) · [`adb.md`](references/adb.md)
- [`references/burp-suite.md`](references/burp-suite.md) · [`frida.md`](references/frida.md) · [`ssl-pinning.md`](references/ssl-pinning.md)
- [`references/reverse-engineering.md`](references/reverse-engineering.md) — JADX, Apktool, Scrcpy, Objection
- [`references/commands.md`](references/commands.md) — per-OS command cheat sheet
- [`references/troubleshooting.md`](references/troubleshooting.md) · [`references/security.md`](references/security.md)
- [`README.md`](README.md) — how each agent discovers/loads this skill, example prompts, updating

**The repository is always authoritative.** If a command here differs from the
current `BurpNinja.sh`/`.ps1`/`bypass.js`, trust the repo, run `driver.sh
doctor`/`check`, and flag the drift. See "Version awareness" in
[`references/architecture.md`](references/architecture.md).
