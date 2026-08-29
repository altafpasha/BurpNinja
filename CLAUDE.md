# CLAUDE.md — BurpNinja

Project context for Claude Code. Claude Code also auto-discovers the skill at
[`.claude/skills/run-burpninja/`](.claude/skills/run-burpninja/) — it surfaces
as the `/run-burpninja` slash command and loads automatically when you ask to
run, set up, screenshot, or troubleshoot BurpNinja.

## What to read

The single source of truth is
**[`.claude/skills/run-burpninja/SKILL.md`](.claude/skills/run-burpninja/SKILL.md)**.
Follow it. The **repository is always authoritative** over documentation — if
a command differs from the current `BurpNinja.sh` / `BurpNinja.ps1` /
`bypass.js`, trust the repo and run `driver.sh doctor` / `check`.

## Quick start

```bash
.claude/skills/run-burpninja/driver.sh doctor   # read-only env report, run first
.claude/skills/run-burpninja/driver.sh check    # syntax-check the scripts
.claude/skills/run-burpninja/driver.sh menu 3   # drive the menu headlessly
```

## Safety

Authorized testing only. Explain and confirm device-modifying actions
(cert install, `/system` remount, frida-server push, script injection); prefer
reversible steps; never expose secrets. See
[`.claude/skills/run-burpninja/references/security.md`](.claude/skills/run-burpninja/references/security.md).

> Other agents (Codex, Cursor, Gemini, Antigravity, …) read [`AGENTS.md`](AGENTS.md)
> at the repo root instead of this file.
