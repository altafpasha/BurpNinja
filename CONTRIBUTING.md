# Contributing to BurpNinja

Welcome to the **BurpNinja** project!

BurpNinja is an automated Android application security testing and lab setup toolkit designed for authorized security researchers, penetration testers, Android developers, DevSecOps engineers, and bug bounty hunters.

We welcome contributions from the community — whether fixing a bug, improving platform compatibility, expanding Frida bypasses, refining documentation, or enhancing AI agent skills.

---

## Table of Contents

- [1. Code of Conduct](#1-code-of-conduct)
- [2. What You Can Contribute](#2-what-you-can-contribute)
- [3. Before You Start](#3-before-you-start)
- [4. Development Environment](#4-development-environment)
- [5. Project Structure](#5-project-structure)
- [6. Making Changes](#6-making-changes)
- [7. Security Contributions](#7-security-contributions)
- [8. Testing](#8-testing)
- [9. Shell Script Guidelines (`BurpNinja.sh`)](#9-shell-script-guidelines-burpninjash)
- [10. PowerShell Guidelines (`BurpNinja.ps1`)](#10-powershell-guidelines-burpninjaps1)
- [11. JavaScript / Frida Guidelines (`bypass.js`)](#11-javascript--frida-guidelines-bypassjs)
- [12. AI Skill Contributions](#12-ai-skill-contributions)
- [13. Commit Messages](#13-commit-messages)
- [14. Pull Requests](#14-pull-requests)
- [15. Pull Request Checklist](#15-pull-request-checklist)
- [16. Bug Reports](#16-bug-reports)
- [17. Feature Requests](#17-feature-requests)
- [18. Documentation Contributions](#18-documentation-contributions)
- [19. Responsible Disclosure](#19-responsible-disclosure)
- [20. License](#20-license)

---

## 1. Code of Conduct

We are committed to providing a welcoming, respectful, and harassment-free environment for all contributors and users.

- **Respectful Communication**: Treat all contributors, maintainers, and community members with courtesy and respect.
- **Constructive Discussions**: Focus discussions on technical merit, actionable feedback, and collaborative problem-solving.
- **Zero Tolerance for Harassment**: Discrimination, hate speech, abusive language, and trolling are strictly prohibited.
- **Responsible Security Testing**: BurpNinja is designed strictly for **authorized** security research, penetration testing under explicit scope, CTF labs, and testing applications/devices you own. Never use or develop features intended for unauthorized access.

---

## 2. What You Can Contribute

Contributions of all types and sizes are encouraged:

| Area | Examples |
|---|---|
| **Android Tooling** | Support for newer Android API levels, Magisk / KernelSU / APatch integrations, root checks, and emulator improvements |
| **Burp Suite Integration** | Certificate export/import enhancements, hash computation (`<hash>.0`), and proxy listener validation |
| **Frida & SSL Pinning** | Adding hooks to `bypass.js`, improving CPU architecture detection (`arm64`, `arm`, `x86_64`, `x86`), and Frida version sync |
| **Platform Compatibility** | macOS (Homebrew, Apple Silicon M1/M2/M3/M4 & Intel), Linux (Debian/Ubuntu, Arch, Fedora), and Windows (PowerShell 5.1+ / 7+) |
| **Error Handling & Resilience** | Timeout handling, graceful fallbacks, non-destructive diagnostics, and cleaner status output |
| **AI Agent Skills** | Improving `.claude/skills/run-burpninja/`, updating reference documents, adding walk-through examples, and refining `driver.sh` |
| **Documentation** | Improving setup guides, troubleshooting scenarios, hardware notes, and manual fallback guides |

---

## 3. Before You Start

Follow this standard GitHub workflow to contribute:

1. **Fork the repository** on GitHub: [altafpasha/BurpNinja](https://github.com/altafpasha/BurpNinja).
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/BurpNinja.git
   cd BurpNinja
   ```
3. **Create a feature branch** with a descriptive name:
   ```bash
   git checkout -b feat/android-14-cert-support
   ```
4. **Make your changes** following the guidelines below.
5. **Test your modifications** in an authorized lab environment.
6. **Review your diff**:
   ```bash
   git diff
   ```
7. **Commit your changes** with a concise, clear message:
   ```bash
   git commit -m "feat: improve certificate remount handling for Android 14"
   ```
8. **Push the branch** to your fork:
   ```bash
   git push origin feat/android-14-cert-support
   ```
9. **Open a Pull Request** against `main` on the upstream repository.

---

## 4. Development Environment

BurpNinja scripts use native tooling and require no heavy build systems.

### macOS
- **OS**: macOS 12+ (Apple Silicon or Intel)
- **Package Manager**: [Homebrew](https://brew.sh)
- **Prerequisites**:
  ```bash
  brew install android-platform-tools openssl python xz
  ```
- **Optional**: `tmux` (for driving the menu harness via `driver.sh`), `node` (for `bypass.js` syntax checks)

### Linux
- **Distributions**: Debian, Ubuntu, Kali, Arch Linux, Fedora
- **Shell**: Bash 4.0+
- **Prerequisites**: `adb`, `openssl`, `python3`, `python3-pip`, `xz-utils`, `curl`, `unzip`
  ```bash
  # Debian/Ubuntu/Kali
  sudo apt install adb openssl python3 python3-pip xz-utils curl unzip

  # Arch Linux
  sudo pacman -S android-tools openssl python-pip xz curl unzip
  ```

### Windows
- **OS**: Windows 10 or 11
- **Shell**: PowerShell 5.1+ or PowerShell 7+
- **Prerequisites**: ADB (Android SDK Platform-Tools), OpenSSL, Python 3, 7-Zip, Scoop (optional)

### Android Target Environment
- Physical device with Developer Options & USB Debugging enabled, **OR**
- Android Emulator (Android Studio AVD, Genymotion)
- Root privileges (Magisk, KernelSU, or `adb root` on userdebug/emulator images)

---

## 5. Project Structure

BurpNinja maintains a lightweight, purposeful directory structure:

```
BurpNinja/
├── BurpNinja.sh                      # Main interactive TUI script for macOS & Linux (Bash)
├── BurpNinja.ps1                     # Main interactive TUI script for Windows (PowerShell)
├── bypass.js                         # Frida JavaScript hook for dynamic SSL-pinning bypass
├── README.md                         # Primary documentation, setup, and usage guide
├── CONTRIBUTING.md                   # Contribution guidelines and development workflows
├── AGENTS.md                         # Cross-tool AI agent instructions & entry point
├── CLAUDE.md                         # Claude Code agent configuration
├── GEMINI.md                         # Gemini CLI & Antigravity fallback configuration
├── .claude/
│   └── skills/
│       └── run-burpninja/            # Universal AI agent skill suite
│           ├── SKILL.md              # Skill instructions & driver documentation
│           ├── driver.sh             # Bash harness for automated checks & TUI control
│           ├── references/           # Detailed topic guides (adb, burp, frida, ssl, etc.)
│           ├── examples/             # Step-by-step setup guides & walk-throughs
│           └── adapters/             # Per-agent loading notes
└── .github/
    └── copilot-instructions.md       # GitHub Copilot agent instructions
```

---

## 6. Making Changes

To keep the codebase maintainable and reliable:

- **Keep changes focused**: Address one bug or feature per PR. Avoid large, unrelated refactors.
- **Preserve existing functionality**: Ensure all interactive menu options (`[1]` to `[10]`) continue to operate as expected.
- **Avoid hardcoded paths**: Never hardcode user-specific paths (e.g. `/Users/username/...` or `C:\Users\username\...`). Use environment variables (`$HOME`, `$LOCALAPPDATA`, `~`) and dynamic directory detection.
- **Never commit secrets**: Do not commit API keys, passwords, private certificates (`*.pem`, `*.der`, `*.0`), or runtime logs. Ensure `.gitignore` is respected.
- **Cross-platform consistency**: When updating shared URLs, tool versions, or workflow steps, keep `BurpNinja.sh` and `BurpNinja.ps1` aligned.

---

## 7. Security Contributions

Because BurpNinja interacts with root privileges, system trust stores, and process instrumentation:

- **Authorized targets only**: Test changes only on devices, emulators, and applications you have explicit permission to test.
- **Prefer disposable environments**: Use Android Studio AVD snapshots or dedicated test hardware rather than personal devices containing personal data.
- **Document security implications**: If a change modifies mount points, certificate stores, SELinux policies, or ADB permissions, clearly explain the change and how it can be reverted.
- **Maintain secret boundaries**: BurpNinja keeps the optional Claude API key **in memory only** for the active session. Never write secrets or API tokens to disk or log files.

---

## 8. Testing

BurpNinja does not use complex automated CI test runners. Use the available validation tools and manual test workflows:

### 1. Static Syntax Checks

Run the built-in driver check (macOS / Linux):
```bash
.claude/skills/run-burpninja/driver.sh check
```

Or run manual syntax checks:
```bash
# Validate Bash script syntax
bash -n BurpNinja.sh

# Validate JavaScript syntax
node --check bypass.js
```

### 2. Environment Doctor (Read-Only)

Verify that BurpNinja's detection logic works correctly on your host without modifying anything:
```bash
.claude/skills/run-burpninja/driver.sh doctor
```

### 3. Headless Menu Verification

Test individual menu options headlessly using `driver.sh`:
```bash
# Test PC Tools check (Option 3)
.claude/skills/run-burpninja/driver.sh menu 3

# Test Device Info check (Option 7)
.claude/skills/run-burpninja/driver.sh menu 7
```

### 4. PowerShell Validation (Windows)

Verify `BurpNinja.ps1` on Windows without executing destructive steps:
```powershell
# Parse and validate PowerShell syntax
Get-Command .\BurpNinja.ps1
```

### 5. Manual End-to-End Testing

Test against an actual connected Android device or emulator:
- **Burp CA Installation (Option 2)**: Ensure certificate is downloaded from Burp (`http://127.0.0.1:8080/cert`), converted to PEM, hashed, and moved into `/system/etc/security/cacerts/`.
- **Frida Server Setup (Option 4 / 5)**: Ensure the matching ABI binary is pushed to `/data/local/tmp/` or `/system/xbin/` and version matches PC client (`frida --version`).
- **SSL Bypass (Option 8)**: Test `bypass.js` against a test app with pinning and verify HTTPS traffic reaches Burp Suite.

---

## 9. Shell Script Guidelines (`BurpNinja.sh`)

When contributing to `BurpNinja.sh`:
- **Shell Compatibility**: Use portable Bash syntax.
- **Quote Variables**: Always quote variable expansions: `"$VAR"`, `"$@"` to prevent word-splitting and globbing bugs.
- **Defensive Execution**: Use `set -euo pipefail` where applicable, and handle anticipated non-zero exit codes gracefully.
- **Dependency Checks**: Check if tools exist using `command -v <tool> &>/dev/null` before executing.
- **macOS & Linux Distinction**:
  - On macOS, run as standard user (`./BurpNinja.sh`) so Homebrew runs in user space.
  - On Linux, check for root privileges (`sudo bash BurpNinja.sh`).
- **Output Consistency**: Use existing output helpers: `ok`, `err`, `warn`, `info`, and `section`.

---

## 10. PowerShell Guidelines (`BurpNinja.ps1`)

When contributing to `BurpNinja.ps1`:
- **Version Compatibility**: Maintain compatibility with PowerShell 5.1 (built into Windows 10/11) and PowerShell Core 7+.
- **Error Handling**: Use structured `try { ... } catch { ... }` blocks and check `$LASTEXITCODE` after external commands.
- **Avoid Hardcoded Paths**: Use standard environment variables (`$env:TEMP`, `$env:USERPROFILE`, `$env:LOCALAPPDATA`).
- **Clean Output**: Follow the color and output style established in the script.

---

## 11. JavaScript / Frida Guidelines (`bypass.js`)

When modifying `bypass.js`:
- **Fault-Tolerant Hooks**: Wrap each hooking section in individual `try { ... } catch (err) { ... }` blocks so one unsupported framework does not prevent other hooks from running.
- **Universal Targeting**: Focus on standard Android and library classes:
  - `javax.net.ssl.TrustManagerImpl`
  - `javax.net.ssl.X509TrustManager`
  - `okhttp3.CertificatePinner`
  - `com.android.org.conscrypt.TrustManagerImpl`
- **Avoid Target-Specific Hacks**: Do not add hooks hardcoded to specific proprietary apps; keep `bypass.js` generic for all Android applications.
- **Frida Compatibility**: Ensure scripts remain compatible with modern Frida 16.x versions.

---

## 12. AI Skill Contributions

BurpNinja ships with an AI Agent Skill under `.claude/skills/run-burpninja/`:
- **Single Source of Truth**: Keep `.claude/skills/run-burpninja/SKILL.md` aligned with actual script capabilities.
- **Agent Agnostic**: Do not add vendor-locked features; ensure instructions work across Claude Code, Antigravity, Cursor, Copilot, Gemini CLI, Aider, and other agents.
- **Accurate Documentation**: Do not document non-existent commands or flags. If you add a new capability to `driver.sh`, update `SKILL.md` accordingly.
- **Keep References Synchronized**: When modifying tool workflows, update corresponding files in `references/` and `examples/`.

---

## 13. Commit Messages

Use clear, concise commit messages that describe the intent of the change:

```text
feat: add APatch root detection support
fix: correct openssl hash calculation on macOS LibreSSL
docs: add troubleshooting steps for Android 14 system cert remount
refactor: streamline frida-server ABI selection logic
security: validate package name input before spawning frida
```

---

## 14. Pull Requests

A great Pull Request includes:
- **Title**: Short, descriptive summary of the change.
- **Description**: Explain what was changed, why it was needed, and any context or issue links.
- **Testing Done**: List the operating systems, Android versions/emulators, and steps you tested.
- **Screenshots / Logs**: Include terminal output or screenshots when modifying TUI menus or banner elements.

---

## 15. Pull Request Checklist

Before submitting your PR, please verify:

- [ ] I tested my changes on an actual device, emulator, or using `driver.sh`.
- [ ] I ran `.claude/skills/run-burpninja/driver.sh check` (or `bash -n` / `node --check`) with no syntax errors.
- [ ] I reviewed `git diff` to ensure no unintended modifications or scratch files are included.
- [ ] I did NOT commit any secrets, API keys, private certificates, or sensitive target data.
- [ ] I maintained cross-platform compatibility (macOS, Linux, and/or Windows).
- [ ] I updated `README.md` or skill reference docs if user-facing behavior changed.
- [ ] I tested security-sensitive changes in an authorized lab environment.

---

## 16. Bug Reports

If you encounter an issue or bug, please open an issue on GitHub and provide:

1. **Host Environment**: OS version (macOS / Linux distro / Windows), CPU architecture (`x86_64` / `arm64`).
2. **Android Environment**: Physical device model or Emulator name, Android OS version, API Level, Root method (Magisk, KernelSU, `adb root`).
3. **Tool Versions**: Output of `adb version`, `frida --version`, and Burp Suite version.
4. **Steps to Reproduce**: The menu option selected or command executed.
5. **Observed vs. Expected Behavior**: What happened versus what you expected.
6. **Error Logs**: Copy relevant terminal output or `/tmp/burpninja_log.txt`.

> 🔒 **Redaction Notice**: Please redact sensitive personal information, private IP addresses, API keys, or proprietary package names before submitting logs.

---

## 17. Feature Requests

To suggest a new feature or enhancement, open a GitHub Issue and outline:
- **Problem Statement**: What workflow or friction does this feature solve?
- **Proposed Solution**: How should BurpNinja implement it?
- **Alternatives Considered**: Other tools or approaches you evaluated.
- **Target Compatibility**: Which platforms (macOS / Linux / Windows / Android versions) are affected.

---

## 18. Documentation Contributions

Documentation improvements are always welcome! You can help by:
- Clarifying setup steps in `README.md`.
- Adding troubleshooting scenarios for new Android security restrictions.
- Contributing practical walk-throughs in `.claude/skills/run-burpninja/examples/`.
- Correcting typos and improving readability across all markdown documents.

---

## 19. Responsible Disclosure

BurpNinja is a security research and lab automation utility:
- Do **not** post zero-day exploits, unpatched vulnerabilities in third-party software, or active engagement details in public issues.
- If you discover a security vulnerability within BurpNinja itself, please report it responsibly by contacting the maintainer directly through private GitHub communication or GitHub Security Advisories if available.

---

## 20. License

By contributing to BurpNinja, you agree that your contributions will be licensed under the project's **MIT License** terms (as documented in the repository).

---

<div align="center">

*Thank you for helping build a better Android security testing toolkit for the community!* 🥷📱

</div>
