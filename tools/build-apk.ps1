param(
    [string]$ProjectPath = (Split-Path -Parent $PSScriptRoot),
    [string]$GradleWrapper = "",
    [string]$UnityAndroidRoot = "C:\Users\Georgeous\Unity\Hub\Editor\6000.2.7f2\Editor\Data\PlaybackEngines\AndroidPlayer",
    [string]$OutputApk = ""
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)
if ([string]::IsNullOrWhiteSpace($GradleWrapper)) {
    $GradleWrapper = Join-Path $ProjectPath 'gradlew.bat'
}

if (-not (Test-Path -LiteralPath $GradleWrapper)) {
    throw "Gradle wrapper not found: $GradleWrapper"
}

$jdk = Join-Path $UnityAndroidRoot 'OpenJDK'
if (Test-Path -LiteralPath $jdk) {
    $env:JAVA_HOME = $jdk
    $env:PATH = (Join-Path $jdk 'bin') + [IO.Path]::PathSeparator + $env:PATH
}
elseif (Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.gradle\jdks\temurin-17\bin\java.exe')) {
    $jdk = Join-Path $env:USERPROFILE '.gradle\jdks\temurin-17'
    $env:JAVA_HOME = $jdk
    $env:PATH = (Join-Path $jdk 'bin') + [IO.Path]::PathSeparator + $env:PATH
}

$sdk = Join-Path $UnityAndroidRoot 'SDK'
if (-not (Test-Path -LiteralPath (Join-Path $sdk 'platforms'))) {
    $fallbackUnityAndroidRoot = Join-Path $env:USERPROFILE 'UnityEditors\6000.0.26f1-full\Editor\Data\PlaybackEngines\AndroidPlayer'
    $fallbackSdk = Join-Path $fallbackUnityAndroidRoot 'SDK'
    if (Test-Path -LiteralPath (Join-Path $fallbackSdk 'platforms')) {
        $sdk = $fallbackSdk
    }
}
if (Test-Path -LiteralPath (Join-Path $sdk 'platforms')) {
    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk
    $env:PATH = (Join-Path $sdk 'platform-tools') + [IO.Path]::PathSeparator + $env:PATH
}

& $GradleWrapper -p $ProjectPath --no-daemon :app:assembleDebug
if ($LASTEXITCODE -ne 0) {
    throw "Gradle APK build failed with exit code $LASTEXITCODE"
}

if ([string]::IsNullOrWhiteSpace($OutputApk)) {
    $OutputApk = Join-Path $ProjectPath 'Builds\SAMQuestionnaireVR-2D.apk'
}

$source = Join-Path $ProjectPath 'app\build\outputs\apk\debug\app-debug.apk'
if (-not (Test-Path -LiteralPath $source)) {
    throw "Expected APK not found: $source"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputApk) | Out-Null
Copy-Item -LiteralPath $source -Destination $OutputApk -Force
Write-Host "Built APK: $OutputApk"
