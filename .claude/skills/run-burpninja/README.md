# Universal BurpNinja Skill

A **portable, agent-agnostic AI skill** for operating, configuring,
troubleshooting, and extending [BurpNinja](https://github.com/altafpasha/BurpNinja)
— an Android application-security lab-setup toolkit.

The skill is plain Markdown plus one portable bash driver. It works with any
AI coding/security agent that can read files and (optionally) run shell
commands. **No vendor API is required** — not OpenAI, Anthropic, Gemini,
Copilot, Cursor, or MCP. "Markdown + an agent + optional terminal" is enough.

> **Scope:** authorized penetration testing, app-security testing, CTFs, and
> Android labs on devices/apps you own or are permitted to test. See
> [`references/security.md`](references/security.md).

## What BurpNinja does (source of truth = the repo)

BurpNinja is an interactive terminal menu — `BurpNinja.sh` (macOS/Linux),
`BurpNinja.ps1` (Windows) — that automates:

- Installing the **Burp Suite CA** into the Android **system** trust store.
- Deploying a **Frida server** matched to the device ABI (Magisk module or
  manual binary) and keeping PC ↔ device Frida versions in sync.
- A one-click **SSL-pinning bypass** via `bypass.js` (TrustManager, OkHttp3
  CertificatePinner, NetworkSecurityConfig, WebView, Trustkit) plus proxy
  routing hooks.
- Installing **PC tools** — JADX, Apktool, Scrcpy, Frida, Objection.
- Installing **Android helper apps** — ProxyToggle, ProxyDroid, ADB WiFi,
  F-Droid, Aurora Store.
- Optional **AI mode** (Anthropic Claude API) that diagnoses errors. Purely
  optional; nothing else depends on it.

The skill never invents capabilities beyond what the repository implements.

## Skill layout

```
run-burpninja/
├── SKILL.md              # Primary entry point — driver-first, short
├── README.md             # This file
├── LICENSE               # MIT
├── driver.sh             # The harness: doctor / check / menu / tui / send / capture / kill
├── references/           # Deep, modular docs (optional enhancements)
│   ├── architecture.md   # Components, capability model, version awareness
│   ├── installation.md
│   ├── macos.md  linux.md  windows.md
│   ├── android-setup.md  adb.md
│   ├── burp-suite.md  frida.md  ssl-pinning.md
│   ├── reverse-engineering.md
│   ├── troubleshooting.md  security.md  commands.md
├── examples/             # Walk-throughs
│   ├── first-time-setup.md  android-emulator.md  physical-device.md
│   ├── burp-setup.md  frida-setup.md  troubleshooting.md
└── adapters/             # OPTIONAL per-agent loading notes (no core dependency)
    ├── generic.md  claude.md  codex.md  gemini.md  copilot.md
```

`SKILL.md` is usable **on its own**. Everything under `references/`,
`examples/`, and `adapters/` is an optional enhancement — if a platform only
ingests a single file, feed it `SKILL.md`.

## 1. Installing the skill in different AI agents

The skill is just files in a directory. This repo already ships the standard
**agent entry-point files at the repo root**, so most agents discover it with
**zero setup** — they read one of these and it points here:

| Root file | Read by |
|---|---|
| `AGENTS.md` | The cross-tool standard — Codex, Cursor, Gemini CLI, Google Jules, **Antigravity**, Aider, Zed, Windsurf, Copilot, Devin, and 30+ others |
| `CLAUDE.md` + `.claude/skills/run-burpninja/` | Claude Code (auto-loads as `/run-burpninja`) |
| `GEMINI.md` | Gemini CLI / Antigravity fallback (after `AGENTS.md`) |
| `.github/copilot-instructions.md` | GitHub Copilot |

All of them point to `SKILL.md` as the single source of truth, so there is
nothing to keep in sync.

If your agent isn't covered automatically, "installing" just means pointing it
at `SKILL.md` (that file works standalone):

| Agent | How to load |
|---|---|
| **Claude Code** | Auto: lives at `.claude/skills/run-burpninja/`, surfaces as `/run-burpninja`. |
| **OpenAI Codex** | Auto via root `AGENTS.md`; or attach/paste `SKILL.md`. |
| **Google Antigravity** | Auto via root `AGENTS.md` (native, no setup). See [`adapters/antigravity.md`](adapters/antigravity.md). |
| **Cursor / Windsurf** | Auto via root `AGENTS.md`; or reference `SKILL.md` from a rule. |
| **Gemini CLI / Code Assist** | Auto via `AGENTS.md`/`GEMINI.md`; or `@SKILL.md`. |
| **GitHub Copilot** | Auto via `.github/copilot-instructions.md`; or `#file:SKILL.md`. |
| **Cline / Roo Code / Continue** | Add `SKILL.md` to the context/`@files`. |
| **Aider** | Auto via `AGENTS.md`; or `/read .claude/skills/run-burpninja/SKILL.md`. |
| **OpenHands / Goose / other shell agents** | Mount the repo; the agent runs `driver.sh` directly. |

Per-agent notes (optional) live in [`adapters/`](adapters/):
[`generic`](adapters/generic.md), [`claude`](adapters/claude.md),
[`codex`](adapters/codex.md), [`gemini`](adapters/gemini.md),
[`copilot`](adapters/copilot.md), [`antigravity`](adapters/antigravity.md).
They add nothing the core skill requires — they only translate "load a
Markdown skill and run a shell command" into each platform's idiom.

## 2. How an agent discovers the skill

- **Filename & location.** `SKILL.md` at `.claude/skills/run-burpninja/` is
  the conventional, auto-discovered location for Claude Code and a natural one
  for other agents.
- **Frontmatter `description`.** Written with the verbs an agent matches on:
  *run, launch, drive, set up, screenshot, troubleshoot BurpNinja*. Agents
  that rank skills by description will surface it for those requests.
- **The driver.** `driver.sh doctor` is the self-describing entry point; an
  agent that finds the skill runs it first to learn the current environment.

## 3. Example prompts

- "Run BurpNinja and show me the menu."
- "Set up my Android pentest environment with BurpNinja."
- "BurpNinja isn't working — figure out why." *(→ `driver.sh doctor`, don't reinstall)*
- "Check my Frida client/server versions are in sync."
- "Walk me through installing the Burp CA cert on my emulator."
- "Bypass SSL pinning on `com.example.app` — I own it." *(authorization required)*
- "Take a screenshot of the BurpNinja TUI." *(→ `driver.sh tui` + `capture`)*
- "Decompile this APK — which BurpNinja tool should I use?"

## 4. Supported BurpNinja workflows

Environment detection · ADB connectivity & root check · device/ABI
detection · Burp proxy verification · CA-cert install into the system store ·
Frida server install (Magisk / manual) · Frida version sync · SSL-pinning
bypass injection · PC-tool install · Android-app install · reverse
engineering (JADX/Apktool/Scrcpy/Objection) · device info · optional AI error
analysis. Details per workflow in [`references/`](references/) and
[`examples/`](examples/).

## 5. Required vs optional agent capabilities

**Required:** read files · understand Markdown · follow multi-step
procedures · (to act automatically) execute shell commands and read their
output.

**Optional:** terminal/shell · filesystem write · `adb` · `tmux` · `node` ·
browser · git · MCP · IDE integration · emulator control · an AI-analysis
capability for interpreting errors.

When an optional capability is missing, the agent should **print the exact
command and ask the user to run it and paste the output** rather than assume
it can act. See the capability model in
[`references/architecture.md`](references/architecture.md).

## 6. Security boundaries

Authorized use only. The skill must not help access third-party systems,
devices, apps, accounts, or infrastructure without permission. Before
destructive/outward-facing actions: explain the change, confirm the target,
prefer reversible operations, avoid unrelated system modification. Never
expose secrets, tokens, keys, certs, or personal data. Full model:
[`references/security.md`](references/security.md).

## 7. Known limitations

- BurpNinja needs a **rooted** device/emulator for system-cert install and
  frida-server; unrooted devices are out of scope for those steps.
- `bypass.js` covers common pinning libraries; **not every** pinning
  implementation is defeated by it — some need custom Frida scripts. See the
  "supported vs. requires-research" split in
  [`references/ssl-pinning.md`](references/ssl-pinning.md).
- The SSL-bypass proxy hooks are hard-coded to `10.0.2.2:8080` (AVD host
  alias); physical devices need editing.
- Windows behavior (`BurpNinja.ps1`, Scoop/winget/7-Zip) is documented from
  the repo but was **not executed** in the Linux/macOS container used to build
  this skill — treat [`references/windows.md`](references/windows.md) as
  repo-derived, not runtime-verified.
- AI mode requires an Anthropic key and network; it is optional and off by
  default.

## 8. Updating the skill when BurpNinja changes

The **repository is always authoritative.** When BurpNinja changes:

1. Re-inspect `BurpNinja.sh`, `BurpNinja.ps1`, `bypass.js`, `README.md`.
2. Run `driver.sh doctor` and `driver.sh check` against the new version.
3. Prefer current repo behavior over anything written here.
4. Update the affected `references/*` module (they are modular by design so a
   single feature change touches one file).
5. Bump `version:` in `SKILL.md` frontmatter and note the drift.
6. Never blindly run a command from an old reference — verify it still exists
   in the current scripts first (e.g. `grep` the function name).

See "Version awareness" and "Extensibility" in
[`references/architecture.md`](references/architecture.md).
