# Adapter: generic (any Markdown/instruction agent)

Optional. The core skill (`SKILL.md` + `driver.sh`) needs no adapter. This
file only restates how a generic agent should consume it.

## Load

Read `SKILL.md`. If the platform ingests one file, that is enough. Pull in
`references/*` and `examples/*` on demand when a task needs the detail.

## Operate

1. Run `.claude/skills/run-burpninja/driver.sh doctor` (read-only) first.
2. Use `driver.sh check`, `menu`, `tui`/`send`/`capture` per `SKILL.md`.
3. Treat the **repository as authoritative** — if a command differs from the
   current `BurpNinja.sh`/`.ps1`/`bypass.js`, trust the repo and flag drift.

## Capability fallback

```
If terminal execution is available:
    run the command; interpret the output.
Otherwise:
    give the exact command to the user; ask them to paste the result.
```

Never assume a tool exists — probe via `doctor` or `command -v`.

## Safety

Authorized targets only. Explain device-modifying actions, confirm the target,
prefer reversible steps, never expose secrets. See
[`../references/security.md`](../references/security.md).
