# GEMINI.md — BurpNinja

Context for Gemini CLI and Google Antigravity (fallback after `AGENTS.md`).
Prefer [`AGENTS.md`](AGENTS.md) — it is the cross-tool source and both tools
read it first (priority `AGENTS.md → GEMINI.md → defaults`).

BurpNinja is an interactive terminal menu (`BurpNinja.sh` / `BurpNinja.ps1`)
for authorized Android app-security lab setup — Burp CA cert, Frida server,
SSL-pinning bypass (`bypass.js`), JADX/Apktool/Scrcpy/Objection.

## Read this first

Canonical instructions:
[`.claude/skills/run-burpninja/SKILL.md`](.claude/skills/run-burpninja/SKILL.md).
The **repository is authoritative** over documentation.

## Drive it (repo root, macOS/Linux)

```bash
.claude/skills/run-burpninja/driver.sh doctor   # read-only env report — run first
.claude/skills/run-burpninja/driver.sh check    # syntax-check scripts
.claude/skills/run-burpninja/driver.sh menu 3   # drive the TUI headlessly
```

## Rules & safety

"Set up" → doctor → check OS/deps/ADB/ABI/root → configure → verify → report.
"Isn't working" → doctor → diagnose one component → smallest fix → verify;
don't mass-reinstall. Authorized targets only; confirm device-modifying
actions; never expose secrets. See
[`.claude/skills/run-burpninja/references/security.md`](.claude/skills/run-burpninja/references/security.md).
