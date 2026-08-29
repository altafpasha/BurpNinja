# Adapter: OpenAI Codex / ChatGPT agents

Optional. No OpenAI-specific API is required by the skill.

## Load

Attach or paste `SKILL.md` into the agent's context. If the agent supports
file references, point it at `.claude/skills/run-burpninja/SKILL.md` and the
`references/`/`examples/` files it needs.

## Operate

- If the agent has a terminal/sandbox: run
  `.claude/skills/run-burpninja/driver.sh doctor` first, then `check`, `menu`,
  and (where a pseudo-TTY is available) `tui`/`send`/`capture`.
- If the environment has **no tmux or no TTY**, prefer `driver.sh menu <keys>`
  (headless) and avoid `frida-ls-devices`/`frida -U`, which need a TTY. Hand
  those to the user.

## Capability fallback

When execution isn't available, output the exact command and ask the user to
paste the result, then interpret it.

## Safety

Authorized targets only; confirm before device-modifying actions; never echo
secrets. See [`../references/security.md`](../references/security.md). The
repository is authoritative over this documentation.
