# AGENTS.md — BurpNinja

Cross-tool instructions for AI coding/security agents working in this repo.
This file is the **universal entry point** (the `AGENTS.md` standard read by
Codex, Cursor, Gemini CLI, Google Jules, Antigravity, Aider, Zed, Windsurf,
Copilot, Devin, and others). Claude Code uses its own path — see
[`CLAUDE.md`](CLAUDE.md) and [`.claude/skills/run-burpninja/`](.claude/skills/run-burpninja/).

## What this project is

BurpNinja is an interactive terminal menu — `BurpNinja.sh` (macOS/Linux),
`BurpNinja.ps1` (Windows) — that automates Android app-security lab setup:
installing the Burp Suite CA into the Android system trust store, deploying a
Frida server matched to the device ABI, injecting a one-click SSL-pinning
bypass (`bypass.js`), and installing PC tools (JADX, Apktool, Scrcpy, Frida,
Objection).

## The canonical skill (single source of truth)

Full instructions, workflows, references, and safety live in
**[`.claude/skills/run-burpninja/SKILL.md`](.claude/skills/run-burpninja/SKILL.md)**.
Read it first. Everything below is a summary that points back to it — if this
file and `SKILL.md` ever disagree, `SKILL.md` (and then the actual scripts)
win. The **repository is always authoritative** over any documentation.

## How to drive it (the agent path)

BurpNinja is a TUI; drive it with the committed bash harness rather than
launching a blocking menu. From the repo root (macOS/Linux):

```bash
# read-only environment report — ALWAYS run this first
.claude/skills/run-burpninja/driver.sh doctor

# static sanity check of the scripts
.claude/skills/run-burpninja/driver.sh check

# drive the menu headlessly (e.g. option [3] PC Tools), auto-exits
.claude/skills/run-burpninja/driver.sh menu 3

# live interaction in tmux: launch, press a key, snapshot, quit
.claude/skills/run-burpninja/driver.sh tui
.claude/skills/run-burpninja/driver.sh send 3
.claude/skills/run-burpninja/driver.sh capture
.claude/skills/run-burpninja/driver.sh kill
```

Menu: `1` Full Install · `2` Burp cert→Android · `3` PC tools · `4` Frida
server · `5` Fix Frida version · `6` Android apps · `7` Device info · `8`
**SSL bypass** · `9` AI mode · `0` Exit. Options `2,4,5,6,7,8` need a
connected, rooted device and **`exit` the whole script** if the precondition
fails — see the Gotchas in `SKILL.md`.

## Behavioral rules for agents

- **"Set up BurpNinja"** → inspect env (`driver.sh doctor`), determine OS,
  check deps, check ADB connectivity, determine ABI + root, configure missing
  pieces, verify each stage, report status. Don't reinstall blindly.
- **"BurpNinja isn't working"** → do **not** reinstall everything. Run
  `driver.sh doctor`, identify the failing component, run one minimal
  diagnostic, apply the smallest fix, verify.
- **Missing capability** → if you cannot run shell/adb, print the exact
  command and ask the user to paste the output; never assume a tool exists.
- **No vendor lock-in** → nothing here requires any AI/LLM API. BurpNinja's
  own "AI mode" (menu `[9]`, Anthropic key) is optional and unrelated to the
  agent running these instructions.

## Safety (required)

Authorized testing only — apps/devices you own or are permitted to test.
Installing the Burp CA system-wide and disabling SSL pinning weaken device
security: use dedicated test devices/emulators. Before any device-modifying
action (cert install, `/system` remount, frida-server push, script
injection): explain the change, confirm the target, prefer reversible steps.
Never expose or commit secrets, keys, certs, or personal data. Full model:
[`.claude/skills/run-burpninja/references/security.md`](.claude/skills/run-burpninja/references/security.md).

## Deeper references

- Per-topic: [`references/`](.claude/skills/run-burpninja/references/) — adb, burp-suite, frida, ssl-pinning, reverse-engineering, per-OS, troubleshooting, commands
- Walk-throughs: [`examples/`](.claude/skills/run-burpninja/examples/)
- Per-agent loading notes: [`adapters/`](.claude/skills/run-burpninja/adapters/)
