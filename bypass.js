// ============================================================
//  BurpNinja - Frida SSL Bypass Script
//  Author  : @altafpasha
//  Version : 1.0
//  Usage   : frida -U -f <package> -l bypass.js
// ============================================================

Java.perform(function () {
    console.log("============================================");
    console.log("[+] BurpNinja SSL Bypass - @altafpasha");
    console.log("============================================");

    // ── Force Proxy Routing (Burp Suite: 10.0.2.2:8080) ───
    try {
        var System = Java.use('java.lang.System');
        System.setProperty('http.proxyHost', '10.0.2.2');
        System.setProperty('http.proxyPort', '8080');
        System.setProperty('https.proxyHost', '10.0.2.2');
        System.setProperty('https.proxyPort', '8080');
        console.log('[+] System proxy properties set to 10.0.2.2:8080');
    } catch (e) {}

    try {
        var Proxy = Java.use('java.net.Proxy');
        var InetSocketAddress = Java.use('java.net.InetSocketAddress');
        var ProxyType = Java.use('java.net.Proxy$Type');
        var burpProxy = Proxy.$new(ProxyType.HTTP.value, InetSocketAddress.$new('10.0.2.2', 8080));

        var OkHttpClientBuilder = Java.use('okhttp3.OkHttpClient$Builder');
        OkHttpClientBuilder.build.implementation = function () {
            this.proxy(burpProxy);
            return this.build();
        };
        console.log('[+] OkHttpClient forced to route via 10.0.2.2:8080');
    } catch (e) {}

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
            console.log('[+] OkHttp3 CertificatePinner check(String, List) bypassed');
        };
        CertificatePinner.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;').implementation = function () {
            console.log('[+] OkHttp3 CertificatePinner check(String, Certs) bypassed');
        };
    } catch (e) {}

    // ── Android 7+ Network Security Config bypass ─────────
    try {
        var NetworkSecurityConfig = Java.use('android.security.net.config.RootTrustManager');
        NetworkSecurityConfig.checkServerTrusted.implementation = function () {
            console.log('[+] NetworkSecurityConfig bypass applied');
        };
    } catch (e) {}

    // ── WebViewClient SSL Error Bypass ────────────────────
    try {
        var WebViewClient = Java.use('android.webkit.WebViewClient');
        WebViewClient.onReceivedSslError.implementation = function (view, handler, error) {
            console.log('[+] WebViewClient onReceivedSslError bypassed (proceeding)');
            handler.proceed();
        };
    } catch (e) {}

    // ── Trustkit Bypass ───────────────────────────────────
    try {
        var Activity = Java.use('com.datatheorem.android.trustkit.pinning.OkHostnameVerifier');
        Activity.verify.overload('java.lang.String', 'javax.net.ssl.SSLSession').implementation = function () {
            console.log('[+] Trustkit OkHostnameVerifier bypassed');
            return true;
        };
    } catch (e) {}

    console.log('[+] All bypass and proxy hooks active. Intercepting traffic in Burp!');
});
