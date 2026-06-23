@echo off
setlocal

if "%UNITY_ANDROID_ROOT%"=="" set "UNITY_ANDROID_ROOT=C:\Users\Georgeous\Unity\Hub\Editor\6000.2.7f2\Editor\Data\PlaybackEngines\AndroidPlayer"
set "UNITY_ANDROID_SDK_ROOT=C:\Users\Georgeous\UnityEditors\6000.0.26f1-full\Editor\Data\PlaybackEngines\AndroidPlayer"
if "%JAVA_HOME%"=="" (
  if exist "%UNITY_ANDROID_ROOT%\OpenJDK\bin\java.exe" (
    set "JAVA_HOME=%UNITY_ANDROID_ROOT%\OpenJDK"
  ) else if exist "%USERPROFILE%\.gradle\jdks\temurin-17\bin\java.exe" (
    set "JAVA_HOME=%USERPROFILE%\.gradle\jdks\temurin-17"
  ) else if exist "%UNITY_ANDROID_SDK_ROOT%\OpenJDK\bin\java.exe" (
    set "JAVA_HOME=%UNITY_ANDROID_SDK_ROOT%\OpenJDK"
  )
)
if "%ANDROID_HOME%"=="" (
  if exist "%UNITY_ANDROID_ROOT%\SDK\platforms" (
    set "ANDROID_HOME=%UNITY_ANDROID_ROOT%\SDK"
  ) else if exist "%UNITY_ANDROID_SDK_ROOT%\SDK\platforms" (
    set "ANDROID_HOME=%UNITY_ANDROID_SDK_ROOT%\SDK"
  )
)

set "GRADLE_LAUNCHER=%UNITY_ANDROID_ROOT%\Tools\gradle\lib\gradle-launcher-8.11.jar"

if not exist "%JAVA_HOME%\bin\java.exe" (
  echo Java not found at "%JAVA_HOME%\bin\java.exe"
  exit /b 1
)

if not exist "%ANDROID_HOME%\platforms" (
  echo Android SDK not found at "%ANDROID_HOME%"
  exit /b 1
)

if not exist "%GRADLE_LAUNCHER%" (
  echo Gradle launcher not found at "%GRADLE_LAUNCHER%"
  exit /b 1
)

"%JAVA_HOME%\bin\java.exe" -classpath "%GRADLE_LAUNCHER%" org.gradle.launcher.GradleMain %*
exit /b %ERRORLEVEL%
