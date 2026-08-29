# Security & safety model

## Intended use

BurpNinja and this skill are for **authorized** work only:

- Penetration testing under contract/scope.
- Application-security testing of apps you own or are permitted to test.
- CTFs and controlled Android labs.
- Security research on devices/emulators you control.

## Not permitted

Do not use this skill to help access third-party systems, devices,
applications, accounts, or infrastructure **without explicit authorization**.
If a request implies testing an app the user does not own or clearly control,
ask for confirmation of authorization before proceeding with device-modifying
or bypass steps.

## Before any destructive or device-modifying action

The high-impact actions here are: installing a CA into the **system** trust
store, remounting `/system` read-write, pushing/executing `frida-server`,
installing APKs, and injecting Frida scripts into a running app.

1. **Explain what will change** (what file/store/process, on which device).
2. **Confirm the target** — device serial and app package.
3. **Prefer reversible operations** — a disposable emulator/snapshot over a
   daily-driver device; note how to undo (remove the `<hash>.0` cert, kill
   frida-server, uninstall APKs).
4. **Avoid unrelated system modification** — touch only what the task needs.

## Posture warning

Installing the Burp CA system-wide and disabling SSL pinning **weaken the
device's security**. Only do this on dedicated test devices/emulators, never
on a device holding real personal or corporate data.

## Secrets

- **Never print, log, or commit** API keys, tokens, private keys, certs, or
  personal data. BurpNinja keeps the optional Anthropic key **in memory only**
  (never written to disk) and validates the `sk-ant-` format before use.
- The repo `.gitignore` already excludes certs (`*.der`, `*.pem`, `*.0`),
  frida binaries, logs, `.env*`, and `*.secret` — keep it that way.
- When sharing `doctor` output, it contains device model/serial — treat as
  mildly sensitive.

## Agent conduct

- Use the read-only `driver.sh doctor` first; don't run installers or
  device-modifying menu options speculatively.
- If a required capability (terminal, adb) is missing, hand the command to the
  user rather than guessing an outcome.
- Report failures faithfully (show the actual error), and never fabricate
  success.
