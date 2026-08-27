# ==============================================================================
#  ____                   _   _  _         _
# |  _ )_   _ _ __ _ __  | \ | |(_)_ __  (_) __ _
# | |_) | | | | '__| '_ \ |  \| || | '_ \ | |/ _`|
# |  _ <| |_| | |  | |_) || |\  || | | | || | (_| |
# |_|_\_\\__,_|_|  | .__/ |_| \_||_|_| |_||_|\__,_|
#                   |_|
# ==============================================================================
#  Android Pentesting Setup Toolkit  |  Windows Edition
#  Author  : @altafpasha
#  Version : 2.0.0
#  Compat  : PowerShell 5.1+
# ==============================================================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8

# ------------------------------------------------------------------------------
#  GLOBALS
# ------------------------------------------------------------------------------
$script:BurpIP       = "127.0.0.1:8080"
$script:BaseDir      = Join-Path $env:TEMP "burpninja_workspace"
$script:LogFile      = Join-Path $env:TEMP "burpninja_log.txt"
$script:AiEnabled    = $false
$script:AnthropicKey = ""
$script:Version      = "2.0.0"

# ------------------------------------------------------------------------------
#  LOGGING
# ------------------------------------------------------------------------------
function Write-Log {
    param([string]$Msg, [string]$Lvl = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$ts][$Lvl] $Msg" | Out-File -Append -FilePath $script:LogFile -Encoding UTF8
}

# ------------------------------------------------------------------------------
#  OUTPUT HELPERS
# ------------------------------------------------------------------------------
function OK   ([string]$m) { Write-Host "[+] $m" -ForegroundColor Green;   Write-Log $m "OK" }
function ERR  ([string]$m) { Write-Host "[!] $m" -ForegroundColor Red;     Write-Log $m "ERROR" }
function WARN ([string]$m) { Write-Host "[~] $m" -ForegroundColor Yellow;  Write-Log $m "WARN" }
function INFO ([string]$m) { Write-Host "[*] $m" -ForegroundColor Cyan;    Write-Log $m "INFO" }

function Write-Section ([string]$Title) {
    $pad = "-" * (52 - $Title.Length)
    Write-Host ""
    Write-Host "  +-- $Title $pad" -ForegroundColor DarkCyan
}

# ------------------------------------------------------------------------------
#  BANNER
# ------------------------------------------------------------------------------
function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ____                   _   _  _         _           " -ForegroundColor Cyan
    Write-Host " |  _ )_   _ _ __ _ __  | \ | |(_)_ __  (_) __ _     " -ForegroundColor Cyan
    Write-Host " | |_) | | | | '__| '_ \ |  \| || | '_ \ | |/ _`` |  " -ForegroundColor DarkCyan
    Write-Host " |  _ <| |_| | |  | |_) || |\  || | | | || | (_| |   " -ForegroundColor DarkCyan
    Write-Host " |_|_\_\\__,_|_|  | .__/ |_| \_||_|_| |_||_|\__,_|   " -ForegroundColor DarkCyan
    Write-Host "                   |_|                                 " -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
    $aiTag = if ($script:AiEnabled) { "  | AI: ON [Claude]" } else { "  | AI: OFF" }
    Write-Host "   Android Pentesting Setup Toolkit  |  Windows  |  v$($script:Version)  $aiTag" -ForegroundColor White
    Write-Host "   Author: @altafpasha" -ForegroundColor Gray
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# ------------------------------------------------------------------------------
#  AI -- ANTHROPIC CLAUDE API
# ------------------------------------------------------------------------------
function Invoke-AIAnalysis {
    param([string]$Context, [string]$Command, [string]$Output)
    if (-not $script:AiEnabled) { return }

    Write-Section "AI Error Analysis"
    INFO "Querying Claude AI..."

    $prompt = "You are an expert Android pentesting assistant (Burp Suite / Frida / ADB / Windows).`n" +
              "BurpNinja hit an error. Give a concise diagnosis.`n`n" +
              "CONTEXT: $Context`nCOMMAND: $Command`nOUTPUT: $Output`n`n" +
              "Respond in exactly this format:`n" +
              "DIAGNOSIS: <one line>`nFIX: <exact command or step>`nPREVENTION: <one tip>"

    $bodyObj = @{
        model      = "claude-sonnet-4-20250514"
        max_tokens = 400
        messages   = @(@{ role = "user"; content = $prompt })
    }
    $bodyJson = $bodyObj | ConvertTo-Json -Depth 6

    try {
        $resp = Invoke-RestMethod `
            -Uri "https://api.anthropic.com/v1/messages" `
            -Method POST `
            -Headers @{
                "x-api-key"         = $script:AnthropicKey
                "anthropic-version" = "2023-06-01"
                "content-type"      = "application/json"
            } `
            -Body $bodyJson `
            -TimeoutSec 15 `
            -ErrorAction Stop

        $text = $resp.content[0].text
        Write-Host ""
        foreach ($line in ($text -split "`n")) {
            if     ($line -match "^DIAGNOSIS:")   { Write-Host "  $line" -ForegroundColor Yellow }
            elseif ($line -match "^FIX:")         { Write-Host "  $line" -ForegroundColor Green }
            elseif ($line -match "^PREVENTION:")  { Write-Host "  $line" -ForegroundColor Cyan }
        }
        Write-Host ""
        Write-Log "AI: $text" "AI"
    }
    catch {
        WARN "AI analysis failed: $_"
    }
}

function Invoke-AILogReview {
    if (-not $script:AiEnabled) { WARN "AI mode is disabled. Enable it from the menu first."; return }
    if (-not (Test-Path $script:LogFile)) { WARN "No log file found yet."; return }

    Write-Section "AI Full Session Review"
    INFO "Sending session log to Claude AI..."

    $logs = Get-Content $script:LogFile -Raw -ErrorAction SilentlyContinue
    if ($logs.Length -gt 4000) { $logs = $logs.Substring($logs.Length - 4000) }

    $prompt = "You are a senior Android pentesting engineer reviewing a BurpNinja session log (Windows).`n" +
              "Summarize what was done, list failures, give a prioritized fix plan.`n`nLOG:`n$logs`n`n" +
              "Format:`nSUMMARY: <2 lines>`nERRORS FOUND: <list or None>`nACTION PLAN:`n1. ...`n2. ..."

    $bodyObj = @{
        model      = "claude-sonnet-4-20250514"
        max_tokens = 600
        messages   = @(@{ role = "user"; content = $prompt })
    }

    try {
        $resp = Invoke-RestMethod `
            -Uri "https://api.anthropic.com/v1/messages" `
            -Method POST `
            -Headers @{
                "x-api-key"         = $script:AnthropicKey
                "anthropic-version" = "2023-06-01"
                "content-type"      = "application/json"
            } `
            -Body ($bodyObj | ConvertTo-Json -Depth 6) `
            -TimeoutSec 25 `
            -ErrorAction Stop

        Write-Host ""
        Write-Host $resp.content[0].text -ForegroundColor White
        Write-Host ""
    }
    catch {
        ERR "AI review failed: $_"
    }
}

function Enable-AIMode {
    Write-Section "Enable AI Mode"
    Write-Host "  Uses Claude (Anthropic) API to analyze errors in real-time." -ForegroundColor Gray
    Write-Host "  Get your key at: https://console.anthropic.com" -ForegroundColor DarkCyan
    Write-Host ""
    $key = Read-Host "  Enter Anthropic API Key (sk-ant-...)"
    $key = $key.Trim()

    if (-not ($key -match "^sk-ant-")) {
        ERR "Invalid key format. Must start with sk-ant-"
        return
    }

    $testBody = @{
        model      = "claude-sonnet-4-20250514"
        max_tokens = 10
        messages   = @(@{ role = "user"; content = "ping" })
    } | ConvertTo-Json -Depth 6

    try {
        Invoke-RestMethod `
            -Uri "https://api.anthropic.com/v1/messages" `
            -Method POST `
            -Headers @{
                "x-api-key"         = $key
                "anthropic-version" = "2023-06-01"
                "content-type"      = "application/json"
            } `
            -Body $testBody `
            -TimeoutSec 10 `
            -ErrorAction Stop | Out-Null

        $script:AnthropicKey = $key
        $script:AiEnabled    = $true
        OK "AI Mode enabled. Claude is watching your back."
    }
    catch {
        ERR "API key validation failed: $_"
    }
}

# ------------------------------------------------------------------------------
#  CONNECTIVITY CHECKS
# ------------------------------------------------------------------------------
function Test-Internet {
    Write-Section "Internet Connectivity"
    if (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet) {
        OK "Internet connection OK"
    }
    else {
        ERR "No internet connection"
        Invoke-AIAnalysis "Internet check failed" "Test-Connection 8.8.8.8" "Timeout"
        Show-Banner; exit
    }
}

function Test-Burpsuite {
    Write-Section "Burp Suite Proxy"

    function Try-Connect ([string]$ip) {
        try {
            $r = Invoke-WebRequest -Uri "http://$ip/" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            return ($r.Content -match "Burp" -or $r.StatusCode -eq 200)
        }
        catch { return $false }
    }

    if (Try-Connect $script:BurpIP) {
        OK "Burp Suite running at $($script:BurpIP)"
        return
    }

    ERR "Burp Suite not detected at $($script:BurpIP)"
    Invoke-AIAnalysis "Burp proxy unreachable" "HTTP GET http://$($script:BurpIP)/" "Connection refused"

    $custom = Read-Host "  Enter Burp proxy address (e.g. 192.168.1.10:8080)"
    if (Try-Connect $custom) {
        $script:BurpIP = $custom
        OK "Burp Suite running at $custom"
    }
    else {
        ERR "Cannot reach Burp at $custom. Exiting."
        Show-Banner; exit
    }
}

function Test-ADB {
    Write-Section "ADB Connection"

    $state = adb get-state 2>&1
    if ($LASTEXITCODE -ne 0) {
        ERR "ADB device not ready: $state"
        Invoke-AIAnalysis "ADB not connected" "adb get-state" $state
        Show-Banner; exit
    }
    OK "ADB connected"

    Write-Section "Root Access"
    $whoami = adb shell "id" 2>$null
    if ($whoami -match "uid=0") {
        OK "Running as root (uid=0)"
        return
    }

    $job  = Start-Job -ScriptBlock { adb shell "su -c 'echo __root_ok__'" 2>$null }
    $done = Wait-Job $job -Timeout 6
    $res  = if ($done) { Receive-Job $job } else { "" }
    Remove-Job $job -Force

    if ($res -match "__root_ok__") {
        OK "Root access OK (su available)"
    }
    else {
        WARN "Root access not available"
        Write-Host "  AVD        : https://github.com/newbit1/rootAVD" -ForegroundColor DarkCyan
        Write-Host "  Genymotion : https://t.ly/n_5F" -ForegroundColor DarkCyan
        Invoke-AIAnalysis "Root access denied" "su -c 'echo test'" "Permission denied"
        Show-Banner; exit
    }
}

# ------------------------------------------------------------------------------
#  CERTIFICATE
# ------------------------------------------------------------------------------
function Install-BurpCertificate {
    Write-Section "Burp Certificate"

    $found = adb shell "su -c 'ls /system/etc/security/cacerts/'" 2>$null | Select-String "9a5ba575.0"
    $go    = "y"

    if ($found) {
        WARN "Existing Burp cert found (9a5ba575.0)"
        $go = Read-Host "  Replace it? [Y/N]"
    }

    if ($go -notmatch "^[Yy]$") { INFO "Certificate unchanged"; return }

    if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
        WARN "OpenSSL not found. Attempting auto-install via Scoop..."

        # Try Scoop first
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            INFO "Installing OpenSSL via Scoop..."
            scoop install openssl 2>$null | Out-Null

            if (Get-Command openssl -ErrorAction SilentlyContinue) {
                OK "OpenSSL installed successfully via Scoop"
            }
            else {
                ERR "Scoop install failed. Install manually from: https://slproweb.com/products/Win32OpenSSL.html"
                Write-Host "  Then add OpenSSL to your PATH and re-run." -ForegroundColor DarkCyan
                return
            }
        }
        # Try Winget as fallback
        elseif (Get-Command winget -ErrorAction SilentlyContinue) {
            INFO "Installing OpenSSL via winget..."
            winget install -e --id ShiningLight.OpenSSL --silent 2>$null | Out-Null

            # Refresh PATH so openssl is found in current session
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path", "User")

            if (Get-Command openssl -ErrorAction SilentlyContinue) {
                OK "OpenSSL installed successfully via winget"
            }
            else {
                ERR "winget install failed. Install manually from: https://slproweb.com/products/Win32OpenSSL.html"
                Write-Host "  Then add OpenSSL to your PATH and re-run." -ForegroundColor DarkCyan
                return
            }
        }
        else {
            ERR "Cannot auto-install OpenSSL (Scoop and winget not found)."
            Write-Host "  Install manually from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor DarkCyan
            Write-Host "  Or install Scoop first:  https://scoop.sh  then run: scoop install openssl" -ForegroundColor DarkCyan
            return
        }
    }

    INFO "Downloading certificate from Burp..."
    try {
        Invoke-WebRequest -Uri "http://$($script:BurpIP)/cert" -OutFile "cacert.der" -UseBasicParsing -ErrorAction Stop
    }
    catch {
        ERR "Download failed: $_"
        Invoke-AIAnalysis "Cert download failed" "GET http://$($script:BurpIP)/cert" $_
        return
    }

    INFO "Converting DER to PEM..."
    & openssl x509 -inform DER -in cacert.der -out cacert.pem 2>$null
    $hash     = (& openssl x509 -inform PEM -subject_hash_old -in cacert.pem 2>$null | Select-Object -First 1).Trim()
    $certName = "$hash.0"
    if (Test-Path cacert.pem) { Rename-Item cacert.pem $certName -Force }

    INFO "Pushing $certName to device..."
    adb push $certName /sdcard/ 2>$null | Out-Null
    adb remount 2>$null | Out-Null
    adb shell "su -c 'mount -o rw,remount /system'" 2>$null | Out-Null
    adb shell "su -c 'mv /sdcard/$certName /system/etc/security/cacerts/'" 2>$null | Out-Null
    adb shell "su -c 'chmod 644 /system/etc/security/cacerts/$certName'" 2>$null | Out-Null
    adb shell "su -c 'chown root:root /system/etc/security/cacerts/$certName'" 2>$null | Out-Null

    OK "Certificate installed. Run: adb reboot"
    Write-Log "Cert installed: $certName"
}

# ------------------------------------------------------------------------------
#  ANDROID APPS
# ------------------------------------------------------------------------------
function Install-AndroidApps {
    Write-Section "Android Apps"

    # --- helper ---
    function Install-OneApp {
        param(
            [string]$PkgName,
            [string]$AppName,
            [string]$Url,
            [string]$OutFile,
            [bool]  $IsZip   = $false,
            [string]$ApkName = "",
            [string]$Grant   = ""
        )

        $already = adb shell "pm list packages" 2>$null | Select-String $PkgName
        if ($already) {
            Write-Host "[=] $AppName already installed" -ForegroundColor DarkGreen
            return
        }

        INFO "Downloading $AppName..."
        try {
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
        }
        catch {
            ERR "Download failed for ${AppName}: $_"
            Invoke-AIAnalysis "App download failed" "Invoke-WebRequest $Url" $_
            return
        }

        if ($IsZip) {
            Expand-Archive -Path $OutFile -DestinationPath "." -Force -ErrorAction SilentlyContinue
        }

        $apk = if ($ApkName) { $ApkName } else { $OutFile }
        $result = adb install -t -r $apk 2>&1

        if ($result -match "Success") {
            if ($Grant) { adb shell "pm grant $Grant" 2>$null | Out-Null }
            OK "$AppName installed"
        }
        else {
            ERR "Install failed for ${AppName}: $result"
            Invoke-AIAnalysis "APK install failed" "adb install $apk" $result
        }
    }

    Install-OneApp `
        -PkgName "com.kinandcarta.create.proxytoggle" `
        -AppName "ProxyToggle" `
        -Url     "https://github.com/theappbusiness/android-proxy-toggle/releases/download/v1.0.1/Proxy.Toggle.v1.0.1.zip" `
        -OutFile "ProxyToggle.zip" `
        -IsZip   $true `
        -ApkName "proxy-toggle.apk" `
        -Grant   "com.kinandcarta.create.proxytoggle android.permission.WRITE_SECURE_SETTINGS"

    Install-OneApp `
        -PkgName "com.sujanpoudel.adbwifi" `
        -AppName "ADB WiFi" `
        -Url     "https://github.com/raoshaab/Andro_set/raw/main/assets/adb_wifi.apk" `
        -OutFile "wifiadb.apk"

    Install-OneApp `
        -PkgName "org.proxydroid" `
        -AppName "ProxyDroid" `
        -Url     "https://github.com/raoshaab/Andro_set/raw/main/assets/org.proxydroid.apk" `
        -OutFile "proxydroid.apk"

    Install-OneApp `
        -PkgName "org.fdroid.fdroid" `
        -AppName "F-Droid" `
        -Url     "https://f-droid.org/F-Droid.apk" `
        -OutFile "fdroid.apk"

    Install-OneApp `
        -PkgName "com.aurora.store" `
        -AppName "Aurora Store" `
        -Url     "https://gitlab.com/AuroraOSS/AuroraStore/-/releases/permalink/latest/downloads/app-release.apk" `
        -OutFile "aurora.apk"
}

# ------------------------------------------------------------------------------
#  PC TOOLS
# ------------------------------------------------------------------------------
function Install-PCTools {
    Write-Section "PC Tools (JADX / Apktool / Scrcpy / Frida / Objection)"

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        WARN "Scoop not found. Install from: https://scoop.sh"
        Write-Host "  Then run: scoop bucket add extras" -ForegroundColor DarkCyan
        Write-Host "            scoop install jadx apktool scrcpy" -ForegroundColor DarkCyan
    }
    else {
        $buckets = scoop bucket list 2>$null
        if ($buckets -notmatch "extras") {
            INFO "Adding scoop extras bucket..."
            scoop bucket add extras 2>$null | Out-Null
        }

        foreach ($tool in @("apktool", "scrcpy")) {
            $chk = scoop list $tool 2>$null
            if (-not $chk) {
                INFO "Installing $tool..."
                scoop install $tool 2>$null | Out-Null
                OK "$tool installed"
            }
            else {
                Write-Host "[=] $tool already installed" -ForegroundColor DarkGreen
            }
        }

        $jadxChk = scoop list jadx 2>$null
        if (-not $jadxChk) {
            INFO "Installing jadx..."
            scoop install extras/jadx 2>$null | Out-Null
            OK "jadx installed"
        }
        else {
            Write-Host "[=] jadx already installed" -ForegroundColor DarkGreen
        }

        OK "JADX / Apktool / Scrcpy ready"
    }

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        ERR "Python not found. Install from: https://python.org"
        return
    }

    $fridaOk     = python -m pip list 2>$null | Select-String "frida"
    $objectionOk = python -m pip list 2>$null | Select-String "objection"

    if ($fridaOk -and $objectionOk) {
        Write-Host "[=] Frida and Objection already installed" -ForegroundColor DarkGreen
    }
    else {
        INFO "Installing Frida + Objection via pip..."
        $result = python -m pip install frida frida-tools objection 2>&1
        if ($LASTEXITCODE -eq 0) {
            OK "Frida + Objection installed"
        }
        else {
            ERR "pip install failed"
            Invoke-AIAnalysis "pip install failed" "pip install frida frida-tools objection" $result
        }
    }
}

# ------------------------------------------------------------------------------
#  FRIDA
# ------------------------------------------------------------------------------
function Get-LatestRelease ([string]$Repo) {
    try {
        $r = Invoke-WebRequest -Uri "https://github.com/$Repo/releases/latest" `
            -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
        return (($r.Headers.Location -split '/')[-1] -replace 'v', '')
    }
    catch { return $null }
}

function Install-MagiskModule {
    $ver = Get-LatestRelease "ViRb3/magisk-frida"
    INFO "Downloading MagiskFrida v$ver..."
    $url = "https://github.com/ViRb3/magisk-frida/releases/download/v$ver/MagiskFrida-$ver.zip"
    Invoke-WebRequest -Uri $url -OutFile "frida_module.zip" -UseBasicParsing
    adb push frida_module.zip /data/local/tmp/ 2>$null | Out-Null
    adb shell "su -c 'magisk --install-module /data/local/tmp/frida_module.zip'" 2>$null | Out-Null
    OK "MagiskFrida module installed"

    INFO "Installing TrustUserCerts module..."
    Invoke-WebRequest `
        -Uri "https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip" `
        -OutFile "trust_module.zip" -UseBasicParsing
    adb push trust_module.zip /data/local/tmp/ 2>$null | Out-Null
    adb shell "su -c 'magisk --install-module /data/local/tmp/trust_module.zip'" 2>$null | Out-Null
    OK "TrustUserCerts module installed"
}

function Install-FridaManual {
    $cpu = (adb shell "getprop ro.product.cpu.abi" 2>$null).Trim()
    $arch = switch -Regex ($cpu) {
        '^x86_64' { 'x86_64'; break }
        '^x86'    { 'x86';    break }
        '^arm64'  { 'arm64';  break }
        '^arm'    { 'arm';    break }
        default   { ERR "Unknown CPU arch: $cpu"; return }
    }

    $ver = Get-LatestRelease "frida/frida"
    INFO "Downloading frida-server v$ver for $arch..."
    $url = "https://github.com/frida/frida/releases/download/$ver/frida-server-$ver-android-$arch.xz"
    Invoke-WebRequest -Uri $url -OutFile "frida-server.xz" -UseBasicParsing

    if (-not (Get-Command 7z -ErrorAction SilentlyContinue)) {
        ERR "7-Zip not found. Install from: https://www.7-zip.org/"
        return
    }
    7z x frida-server.xz -y 2>$null | Out-Null

    $binary = "frida-server-$ver-android-$arch"
    if (-not (Test-Path $binary)) { $binary = "frida-server" }

    adb push $binary /data/local/tmp/frida-server 2>$null | Out-Null
    adb shell "su -c 'chmod 755 /data/local/tmp/frida-server'" 2>$null | Out-Null
    adb shell "su -c 'mount -o rw,remount /system'" 2>$null | Out-Null
    adb shell "su -c 'cp /data/local/tmp/frida-server /system/xbin/frida-server'" 2>$null | Out-Null
    OK "Frida server installed at /system/xbin/frida-server"
    Write-Host "  Start: adb shell `"su -c 'frida-server &'`"" -ForegroundColor DarkCyan
}

function Install-FridaAndroid {
    Write-Section "Frida Server (Android)"
    $existing = adb shell "frida-server --version" 2>$null
    if ($existing) {
        WARN "Frida already installed: $existing"
        $choice = Read-Host "  Upgrade/reinstall? [Y/N]"
        if ($choice -notmatch "^[Yy]$") { return }
    }
    $magisk = adb shell "magisk -v" 2>$null
    if ($magisk -match "MAGISK") { Install-MagiskModule } else { Install-FridaManual }
}

function Repair-FridaVersion {
    Write-Section "Frida Version Sync"
    $latest  = Get-LatestRelease "frida/frida"
    $pcVer   = if (Get-Command frida -ErrorAction SilentlyContinue) { (frida --version 2>$null).Trim() } else { "not installed" }
    $adbVer  = (adb shell "frida-server --version" 2>$null).Trim()

    $pcCol  = if ($pcVer  -eq $latest) { "Green" } else { "Yellow" }
    $adbCol = if ($adbVer -eq $latest) { "Green" } else { "Yellow" }

    Write-Host "  Latest   : $latest" -ForegroundColor White
    Write-Host "  PC       : $pcVer"  -ForegroundColor $pcCol
    Write-Host "  Android  : $adbVer" -ForegroundColor $adbCol
    Write-Host ""

    if ($pcVer -eq $adbVer) { OK "Versions in sync ($pcVer)"; return }
    if ($pcVer -ne $latest) {
        INFO "Upgrading PC frida..."
        python -m pip install frida frida-tools --upgrade --quiet 2>$null | Out-Null
    }
    if ($adbVer -ne $latest) { Install-FridaAndroid }
    OK "Frida sync complete"
}

# ------------------------------------------------------------------------------
#  DEVICE INFO
# ------------------------------------------------------------------------------
function Show-DeviceInfo {
    Write-Section "Device Information"
    $props = @(
        @("Model",    "adb shell getprop ro.product.model"),
        @("Brand",    "adb shell getprop ro.product.brand"),
        @("Android",  "adb shell getprop ro.build.version.release"),
        @("API",      "adb shell getprop ro.build.version.sdk"),
        @("CPU ABI",  "adb shell getprop ro.product.cpu.abi"),
        @("Serial",   "adb get-serialno")
    )
    foreach ($p in $props) {
        $val = (Invoke-Expression $p[1] 2>$null).Trim()
        Write-Host ("  {0,-12}: {1}" -f $p[0], $val) -ForegroundColor White
    }
    Write-Host ""
}

# ------------------------------------------------------------------------------
#  INSTALL ALL
# ------------------------------------------------------------------------------
function Install-All {
    Test-Internet
    Test-Burpsuite
    Test-ADB
    Install-PCTools
    Install-AndroidApps
    Install-FridaAndroid
    Install-BurpCertificate
    Write-Host ""
    OK "All done. Run: adb reboot"
}

# ------------------------------------------------------------------------------
#  FRIDA SSL BYPASS
# ------------------------------------------------------------------------------
function Invoke-SSLBypass {
    Write-Section "Frida SSL Bypass"

    # ── Ask for target package ──────────────────────────────
    $package = (Read-Host "  Enter target package name (e.g. com.target.app)").Trim()
    if ([string]::IsNullOrWhiteSpace($package)) {
        ERR "Package name cannot be empty"
        return
    }

    # ── Write bypass.js to workspace ───────────────────────
    $bypassPath = Join-Path $script:BaseDir "bypass.js"
    $repoBypass = Join-Path (Split-Path $PSCommandPath) "bypass.js"
    if (Test-Path $repoBypass) {
        Copy-Item $repoBypass $bypassPath -Force
        INFO "Using bypass.js from repo: $repoBypass"
    }
    else {
        # Inline fallback
        @'
Java.perform(function () {
    console.log("[+] BurpNinja SSL Bypass Active");
    var X509TrustManager = Java.use("javax.net.ssl.X509TrustManager");
    var SSLContext = Java.use("javax.net.ssl.SSLContext");
    var TrustManager = Java.registerClass({
        name: "dev.asd.test.TrustManager",
        implements: [X509TrustManager],
        methods: {
            checkClientTrusted: function () {},
            checkServerTrusted: function () {},
            getAcceptedIssuers: function () { return []; }
        }
    });
    var SSLContext_init = SSLContext.init.overload(
        "[Ljavax.net.ssl.KeyManager;",
        "[Ljavax.net.ssl.TrustManager;",
        "java.security.SecureRandom"
    );
    SSLContext_init.implementation = function (km, tm, sr) {
        console.log("[+] SSL Pinning Bypassed!");
        SSLContext_init.call(this, km, [TrustManager.$new()], sr);
    };
});
'@ | Out-File -FilePath $bypassPath -Encoding UTF8
        INFO "bypass.js written to: $bypassPath"
    }

    # ── Restart ADB ────────────────────────────────────────
    INFO "Restarting ADB..."
    adb kill-server 2>$null | Out-Null
    adb start-server 2>$null | Out-Null
    adb wait-for-device 2>$null | Out-Null

    # ── Forward Frida ports ────────────────────────────────
    INFO "Forwarding Frida ports (27042, 27043)..."
    adb forward tcp:27042 tcp:27042 2>$null | Out-Null
    adb forward tcp:27043 tcp:27043 2>$null | Out-Null

    # ── Request root ───────────────────────────────────────
    INFO "Requesting ADB root..."
    adb root 2>$null | Out-Null
    Start-Sleep -Seconds 2

    # ── Find frida-server on device ────────────────────────
    $fridaLocations = @("/system/xbin/frida-server", "/data/local/tmp/frida-server")
    $fridaBin = $null
    foreach ($loc in $fridaLocations) {
        $chk = adb shell "test -f $loc && echo yes" 2>$null
        if ($chk -match "yes") { $fridaBin = $loc; break }
    }

    if (-not $fridaBin) {
        WARN "frida-server not found on device."
        WARN "Run option [4] to install Frida first, then retry."
        Invoke-AIAnalysis "frida-server missing" "adb shell test -f /system/xbin/frida-server" "not found"
        return
    }
    OK "Found frida-server at: $fridaBin"

    # ── Kill old instance ──────────────────────────────────
    INFO "Stopping any existing frida-server..."
    adb shell "pkill frida-server" 2>$null | Out-Null
    Start-Sleep -Seconds 1

    # ── Start frida-server ─────────────────────────────────
    INFO "Starting frida-server..."
    adb shell "su -c '$fridaBin &'" 2>$null | Out-Null
    Start-Sleep -Seconds 3

    # ── Check PC frida tool ────────────────────────────────
    if (-not (Get-Command frida -ErrorAction SilentlyContinue)) {
        ERR "frida not found on PC. Run option [3] to install Frida tools first."
        return
    }

    # ── Inject SSL bypass ──────────────────────────────────
    OK "Injecting SSL bypass into: $package"
    Write-Host ""
    Write-Host "  CMD: frida -H 127.0.0.1:27042 -f $package -l bypass.js" -ForegroundColor DarkCyan
    Write-Host ""
    & frida -H 127.0.0.1:27042 -f $package -l $bypassPath
}

# ------------------------------------------------------------------------------
#  MAIN MENU
# ------------------------------------------------------------------------------
function Start-Setup {
    while ($true) {
        Show-Banner

        Write-Host "  SETUP" -ForegroundColor DarkGray
        Write-Host "  [1] Full Install (All)"                                              -ForegroundColor White
        Write-Host "  [2] Move Burp Certificate to Android system"                         -ForegroundColor White
        Write-Host "  [3] PC Tools  (JADX, Apktool, Scrcpy, Frida, Objection)"            -ForegroundColor White
        Write-Host "  [4] Android Frida Server"                                            -ForegroundColor White
        Write-Host "  [5] Fix Frida Version Mismatch"                                      -ForegroundColor White
        Write-Host "  [6] Android Apps  (ProxyToggle, ProxyDroid, ADBWifi, F-Droid, Aurora)" -ForegroundColor White
        Write-Host ""
        Write-Host "  DEVICE" -ForegroundColor DarkGray
        Write-Host "  [7] Device Info"                                                     -ForegroundColor White
        Write-Host ""
        Write-Host "  PENTEST" -ForegroundColor DarkGray
        Write-Host "  [8] Frida SSL Bypass  (auto-start + inject)"                        -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  AI" -ForegroundColor DarkGray
        if ($script:AiEnabled) {
            Write-Host "  [9]  AI Session Review  (analyze full log)" -ForegroundColor Magenta
            Write-Host "  [10] Disable AI Mode"                       -ForegroundColor DarkGray
        }
        else {
            Write-Host "  [9] Enable AI Mode  (Claude API)"           -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "  [0] Exit" -ForegroundColor DarkGray
        Write-Host ""

        $opt = Read-Host "  Select"

        switch ($opt) {
            "1"  { Install-All }
            "2"  { Test-Internet; Test-ADB; Test-Burpsuite; Install-BurpCertificate }
            "3"  { Test-Internet; Install-PCTools }
            "4"  { Test-Internet; Test-ADB; Install-FridaAndroid }
            "5"  { Test-Internet; Test-ADB; Repair-FridaVersion }
            "6"  { Test-Internet; Test-ADB; Install-AndroidApps }
            "7"  { Test-ADB; Show-DeviceInfo }
            "8"  { Test-ADB; Invoke-SSLBypass }
            "9"  {
                if ($script:AiEnabled) { Invoke-AILogReview }
                else                   { Enable-AIMode }
            }
            "10" {
                $script:AiEnabled    = $false
                $script:AnthropicKey = ""
                INFO "AI Mode disabled"
            }
            "0"  { Write-Host ""; exit }
            default { ERR "Invalid option" }
        }

        Write-Host ""
        Read-Host "  Press Enter to return to menu" | Out-Null
    }
}

# ------------------------------------------------------------------------------
#  ENTRY
# ------------------------------------------------------------------------------
if (-not (Test-Path $script:BaseDir)) {
    New-Item -Path $script:BaseDir -ItemType Directory -Force | Out-Null
}
"BurpNinja v$($script:Version) started at $(Get-Date)" | Out-File -FilePath $script:LogFile -Encoding UTF8
Set-Location $script:BaseDir
Start-Setup