[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Serial,
    [string]$SdkRoot = "$env:LOCALAPPDATA/Android/Sdk",
    [string]$JdkRoot = $env:JAVA_HOME,
    [string]$BuildToolsVersion = '36.1.0',
    [switch]$SkipJni
)
$ErrorActionPreference = 'Stop'
$Project = Split-Path $PSScriptRoot -Parent
$Build = Join-Path $Project 'build_arm64'
$Adb = Join-Path $SdkRoot 'platform-tools/adb.exe'
$Log = Join-Path $Build ('regression_' + ($Serial -replace '[^A-Za-z0-9_.-]', '_') + '.log')
$Remote = '/data/local/tmp/arm32bridge-regression'
Set-Content -LiteralPath $Log -Value "Android bridge regression: $Serial"
function Invoke-Adb {
    param([string[]]$NativeArgs)
    $PreviousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $Adb -s $Serial @NativeArgs 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath $Log -Append
        $NativeExit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $PreviousPreference }
    if ($NativeExit -ne 0) { throw "adb failed ($NativeExit): $NativeArgs" }
}
if (-not (Test-Path -LiteralPath "$Build/bridge_regression")) {
    throw 'Build tests first: ./build_arm64.ps1 -BuildTests'
}
Invoke-Adb @('push', "$Build/bridge_regression", $Remote)
# adb push can reset the execute bit even when replacing an existing binary.
Invoke-Adb @('shell', 'chmod', '755', $Remote)
Invoke-Adb @('shell', $Remote, 'invalid-stack')
Invoke-Adb @('shell', $Remote, 'cache-pressure')
Invoke-Adb @('shell', $Remote, 'cache-pressure-thumb')
Invoke-Adb @('shell', $Remote)
Invoke-Adb @('shell', $Remote, 'legacy-condition')
Invoke-Adb @('push', "$Build/bridge_audio_contract", '/data/local/tmp/banner-audio-contract')
Invoke-Adb @('shell', 'chmod', '755', '/data/local/tmp/banner-audio-contract')
Invoke-Adb @('shell', '/data/local/tmp/banner-audio-contract')
if (-not $SkipJni) {
    if (-not $JdkRoot) { throw 'Pass -JdkRoot or set JAVA_HOME to build the ART test.' }
    $JniOut = Join-Path $Build 'jni_test'
    New-Item -ItemType Directory -Force -Path $JniOut | Out-Null
    & "$JdkRoot/bin/javac.exe" --release 8 -Xlint:-options -d $JniOut "$PSScriptRoot/BridgeJniRegression.java"
    if ($LASTEXITCODE -ne 0) { throw 'javac failed' }
    $PreviousJava = $env:JAVA_HOME
    try {
        $env:JAVA_HOME = $JdkRoot
        $JniClasses = @(Get-ChildItem -LiteralPath $JniOut -Filter 'BridgeJniRegression*.class' -File | ForEach-Object { $_.FullName })
        & "$SdkRoot/build-tools/$BuildToolsVersion/d8.bat" --min-api 24 --output $JniOut @JniClasses
        if ($LASTEXITCODE -ne 0) { throw 'd8 failed' }
    } finally { $env:JAVA_HOME = $PreviousJava }
    Invoke-Adb @('push', "$Build/libbridge_jni_regression.so", "$Remote-jni.so")
    Invoke-Adb @('push', "$JniOut/classes.dex", "$Remote.dex")
    Invoke-Adb @('shell', "CLASSPATH=$Remote.dex app_process /system/bin BridgeJniRegression $Remote-jni.so")
}
Write-Output "Test log: $Log"
