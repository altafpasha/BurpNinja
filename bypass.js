// ============================================================
//  BurpNinja - Frida SSL Bypass Script
//  Author  : @altafpasha
//  Version : 1.0
//  Usage   : frida -H 127.0.0.1:27042 -f <package> -l bypass.js --no-pause
// ============================================================

Java.perform(function () {
    console.log("============================================");
    console.log("[+] BurpNinja SSL Bypass - @altafpasha");
    console.log("============================================");

    // ── TrustManager bypass ──────────────────────────────
    var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
    var SSLContext        = Java.use('javax.net.ssl.SSLContext');

    var TrustManager = Java.registerClass({
        name: 'dev.asd.test.TrustManager',
        implements: [X509TrustManager],
        methods: {
            checkClientTrusted: function () {},
            checkServerTrusted: function () {},
            getAcceptedIssuers: function () { return []; }
        }
    });

    var TrustManagers = [TrustManager.$new()];

    var SSLContext_init = SSLContext.init.overload(
        '[Ljavax.net.ssl.KeyManager;',
        '[Ljavax.net.ssl.TrustManager;',
        'java.security.SecureRandom'
    );

    SSLContext_init.implementation = function (keyManager, trustManager, secureRandom) {
        console.log('[+] SSLContext.init hooked — injecting custom TrustManager');
        SSLContext_init.call(this, keyManager, TrustManagers, secureRandom);
    };

    console.log('[+] SSL Pinning Bypass Active');

    // ── OkHttp3 CertificatePinner bypass ─────────────────
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function () {
            console.log('[+] OkHttp3 CertificatePinner bypassed');
        };
    } catch (e) {
        console.log('[-] OkHttp3 CertificatePinner not found (skipping)');
    }

    // ── Android 7+ Network Security Config bypass ─────────
    try {
        var NetworkSecurityConfig = Java.use('android.security.net.config.RootTrustManager');
        NetworkSecurityConfig.checkServerTrusted.implementation = function () {
            console.log('[+] NetworkSecurityConfig bypass applied');
        };
    } catch (e) {
        console.log('[-] NetworkSecurityConfig not found (skipping)');
    }

    console.log('[+] All bypass hooks installed. Happy hacking!');
});
