# Adapter: Claude Code / Claude-based agents

Optional. Uses no Claude-specific API — just describes native discovery.

## Discovery

The skill lives at `.claude/skills/run-burpninja/`. Claude Code auto-discovers
nested `.claude/skills/` directories: it surfaces as the `/run-burpninja`
slash command and auto-loads when a request matches the frontmatter
`description` (run/launch/drive/set up/screenshot/troubleshoot BurpNinja).

## Use

- Invoke explicitly with `/run-burpninja`, or just ask ("run BurpNinja",
  "BurpNinja isn't working") and let it auto-load.
- With Bash permitted, run `driver.sh doctor` / `menu` / `tui` directly.
- `driver.sh tui` uses tmux; `send`/`capture` drive it live.

## Note on BurpNinja's own "AI mode"

BurpNinja has an optional built-in Anthropic-API error analyzer (menu `[9]`).
That is a **feature of BurpNinja**, unrelated to this skill and not required.
Do not conflate it with the agent running the skill. Never enter or store the
user's API key on their behalf.

## Everything else

Follow `SKILL.md` and the generic adapter. Repository is authoritative.
