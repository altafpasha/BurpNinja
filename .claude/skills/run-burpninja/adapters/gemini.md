# Adapter: Gemini CLI / Gemini Code Assist

Optional. No Gemini/Google-specific API is required by the skill.

## Load

Provide `SKILL.md` as context — e.g. `@SKILL.md` (or the full path
`@.claude/skills/run-burpninja/SKILL.md`) in Gemini CLI, or paste it into Code
Assist. Add `references/`/`examples/` files as the task needs them.

## Operate

- Gemini CLI with shell access: run
  `.claude/skills/run-burpninja/driver.sh doctor`, then `check`/`menu`, and
  `tui`/`send`/`capture` when a TTY is available.
- Code Assist (IDE, often no shell): treat the skill as guidance — surface the
  exact commands for the user to run and interpret their pasted output.

## Capability fallback

```
If a shell tool is available: run the command; read the output.
Otherwise: give the command to the user and ask for the result.
```

## Safety

Authorized targets only; confirm device-modifying steps; never expose
secrets. Repository is authoritative. See
[`../references/security.md`](../references/security.md).
