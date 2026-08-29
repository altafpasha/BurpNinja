# Adapter: GitHub Copilot

Optional. No Copilot-specific API is required by the skill.

## Load

- **Copilot Chat:** reference the file — `#file:.claude/skills/run-burpninja/SKILL.md`
  — to bring it into context.
- **Persistent guidance:** copy the key parts of `SKILL.md` (the driver
  commands, gotchas, safety) into `.github/copilot-instructions.md` so they
  apply across the repo.

## Operate

- In an integrated terminal, run
  `.claude/skills/run-burpninja/driver.sh doctor` / `check` / `menu`; use
  `tui`/`send`/`capture` for live driving where a TTY exists.
- Copilot's editor completions won't drive a TUI — use the terminal + driver
  for anything interactive.

## Capability fallback

If Copilot can't run commands in your setup, it should emit the exact command
for you to run, then reason over the output you paste back.

## Safety

Authorized targets only; confirm device-modifying actions; never surface
secrets. The repository is authoritative over this documentation. See
[`../references/security.md`](../references/security.md).
