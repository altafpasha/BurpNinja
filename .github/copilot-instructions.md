# GitHub Copilot instructions — BurpNinja

BurpNinja is an interactive terminal menu (`BurpNinja.sh` / `BurpNinja.ps1`)
for authorized Android app-security lab setup — Burp CA cert, Frida server,
SSL-pinning bypass (`bypass.js`), JADX/Apktool/Scrcpy/Objection.

## Read this first

The canonical instructions live in
[`../.claude/skills/run-burpninja/SKILL.md`](../.claude/skills/run-burpninja/SKILL.md).
The cross-tool summary is in [`../AGENTS.md`](../AGENTS.md). The **repository
is authoritative** over any documentation.

## Drive it (repo root, macOS/Linux)

```bash
.claude/skills/run-burpninja/driver.sh doctor   # read-only env report — run first
.claude/skills/run-burpninja/driver.sh check    # syntax-check scripts
.claude/skills/run-burpninja/driver.sh menu 3   # drive the TUI headlessly
```

Use `tui` / `send` / `capture` / `kill` for live interaction. Editor
completions can't drive the TUI — use the terminal + driver.

## Rules

- "Set up BurpNinja" → run `doctor`, check OS/deps/ADB/ABI/root, configure
  gaps, verify, report. Don't reinstall blindly.
- "Isn't working" → `doctor` → identify component → minimal diagnostic →
  smallest fix → verify. Never mass-reinstall.
- No AI/LLM API is required by these instructions.

## Safety

Authorized targets only. Explain and confirm device-modifying actions; prefer
reversible steps; never surface secrets. See
[`../.claude/skills/run-burpninja/references/security.md`](../.claude/skills/run-burpninja/references/security.md).
