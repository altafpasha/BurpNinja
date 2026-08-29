# Adapter: Google Antigravity

Optional. No Antigravity/Google-specific API is required by the skill.

## Discovery

Antigravity reads **`AGENTS.md`** at the workspace root automatically (native
support since IDE v1.20.x). This repo ships one at the root
([`../../../../AGENTS.md`](../../../../AGENTS.md)), so Antigravity picks up the
BurpNinja instructions with **no setup** — it points into this skill.

Antigravity's config priority is `AGENTS.md → GEMINI.md → built-in defaults`.
Workspace-scoped rules can also live under `.agents/rules/`, and global rules
under `~/.gemini/GEMINI.md` (shared with Gemini CLI — beware cross-leak).

## Operate

- With shell access (Antigravity CLI / agent terminal): run
  `.claude/skills/run-burpninja/driver.sh doctor` first, then `check` / `menu`,
  and `tui` / `send` / `capture` for live driving.
- Follow the behavioral rules in `AGENTS.md` ("set up" → doctor+configure;
  "isn't working" → diagnose, don't reinstall).

## Capability fallback

If a command can't be run, emit the exact command and ask the user to paste
the output, then interpret it.

## Safety

Authorized targets only; confirm device-modifying actions; never expose
secrets. Repository is authoritative. See
[`../references/security.md`](../references/security.md).
