# SSL pinning bypass

**Purpose:** defeat certificate pinning in an **authorized** target app so
its HTTPS traffic can be intercepted in Burp. Implemented by `bypass.js`,
driven by menu `[8]` (`ssl_bypass`).

> Authorization required: only run against apps you own or are explicitly
> permitted to test. See [`security.md`](security.md).

## What `bypass.js` actually does (read the file — it is the source of truth)

`bypass.js` (validated this session with `node --check` → OK) is a single
`Java.perform` block that installs these hooks:

| Hook | What it neutralizes |
|---|---|
| `System.setProperty(http(s).proxyHost/Port)` = `10.0.2.2:8080` | forces JVM proxy to Burp (AVD host alias) |
| `okhttp3.OkHttpClient$Builder.build` → `.proxy(burpProxy)` | routes OkHttp through Burp |
| custom `X509TrustManager` + `SSLContext.init` override | accepts all certs (standard TLS) |
| `okhttp3.CertificatePinner.check(...)` (both overloads) | OkHttp3 pinning no-op |
| `android.security.net.config.RootTrustManager.checkServerTrusted` | Network Security Config (Android 7+) |
| `android.webkit.WebViewClient.onReceivedSslError` → `handler.proceed()` | WebView SSL errors |
| `com.datatheorem.android.trustkit...OkHostnameVerifier.verify` → `true` | Trustkit |

Every hook after the core TrustManager is wrapped in `try/catch`, so classes
the app doesn't use are skipped silently.

### Supported by the existing BurpNinja workflow

Apps pinning via **standard `SSLContext`/TrustManager**, **OkHttp3
CertificatePinner**, **Android Network Security Config**, **WebView**, or
**Trustkit** — the common cases. If interception starts working after
injection, you're in this bucket.

### Requires additional research / custom implementation

`bypass.js` does **not** cover, and you'll need a custom Frida script for:

- Native/NDK pinning (BoringSSL/OpenSSL in `.so`, e.g. `SSL_CTX_set_custom_verify`).
- Flutter apps (pinning inside `libflutter.so`, its own BoringSSL).
- Xamarin, Conscrypt-specific, or Cronet stacks.
- Bespoke/obfuscated pinning, or root/Frida detection that kills the app.
- gRPC/HTTP2 clients not built on OkHttp.

Do **not** claim every pinning implementation can be bypassed — confirm by
observing traffic in Burp, and fall back to `objection`
(`android sslpinning disable`) or a target-specific script.

## Prerequisites

- Rooted device, frida-server installed & running ([`frida.md`](frida.md)).
- PC `frida` present; Burp CA installed ([`burp-suite.md`](burp-suite.md)).
- Target package name (`adb shell pm list packages | grep <name>`).

## Setup / Usage — the `[8]` flow (`ssl_bypass`)

BurpNinja: prompts for the package → copies repo `bypass.js` into its
workspace (inline fallback if absent) → `adb forward tcp:27042/27043` →
locates frida-server → kills any old instance → starts it as a daemon →
injects:

```bash
# Equivalent manual run (.sh edition):
adb shell "nohup /data/local/tmp/frida-server >/dev/null 2>&1 &"
frida -U -f com.target.app -l bypass.js
```

(The `.ps1` edition injects with `frida -H 127.0.0.1:27042 -f <pkg> -l
bypass.js`.) On success the app's console shows the bypass banner and
`[+] SSLContext.init hooked` / `[+] SSL Pinning Bypass Active`.

## Verification

1. In the Frida console you see the `[+] ...` hook lines.
2. In Burp's HTTP history you see the app's HTTPS requests decrypted.
3. No TLS handshake failures in the app.

If (1) prints but (2) doesn't: proxy routing is the problem (wrong host/IP —
`10.0.2.2` is emulator-only), or the app uses a stack the script doesn't hook
(see "requires research" above).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Failed to spawn: unable to find process` | Wrong package name. |
| Hooks print but no traffic in Burp | Proxy target wrong for a physical device — edit `bypass.js` `10.0.2.2` to the host LAN IP, or set a device proxy. |
| App crashes on launch after inject | Root/Frida/pinning-detection; try attach-mode, an anti-root script, or objection. |
| `unable to connect to remote frida-server` | Server not running / port forward missing. |
| Still pinned | Likely native/Flutter/custom pinning → custom script needed. |

## Limitations

`bypass.js` hard-codes `10.0.2.2:8080` for proxy routing (AVD-specific), and
its coverage is the common Java/Kotlin TLS stacks only. It cannot bypass
what it does not hook.
