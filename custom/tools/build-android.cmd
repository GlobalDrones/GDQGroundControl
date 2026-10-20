@echo off
rem Compila uma variante para Android arm64 (gera a .so; o APK sai pelo Qt Creator
rem ou por "make apk"). Uso: custom\tools\build-android.cmd <variante> [pasta-de-build]
rem Pasta padrão: ..\build-<variante>-android. Log em build.log.
rem Caminhos ajustáveis: ANDROID_SDK_ROOT, ANDROID_NDK_ROOT, JAVA_HOME, QT_ANDROID_DIR.
rem O vídeo precisa do GStreamer Android 1.18.6 em src\VideoReceiver\gstreamer-1.0-android-universal-1.18.6.
setlocal
if "%~1"=="" (
  echo Uso: %~nx0 ^<gd25^|gd30^|gd60^|gd70^|gd150^> [pasta-de-build]
  exit /b 1
)
set VARIANT=%~1
set SRCDIR=%~dp0..\..
if not "%~2"=="" (set BUILDDIR=%~2) else (set BUILDDIR=%SRCDIR%\..\build-%VARIANT%-android)
if not defined ANDROID_SDK_ROOT set ANDROID_SDK_ROOT=%LOCALAPPDATA%\Android\Sdk
if not defined ANDROID_NDK_ROOT set ANDROID_NDK_ROOT=%ANDROID_SDK_ROOT%\ndk\21.3.6528147
if not defined JAVA_HOME set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-11.0.31.11-hotspot
if not defined QT_ANDROID_DIR set QT_ANDROID_DIR=C:\Qt\5.15.2\android
set ANDROID_NDK_HOST=windows-x86_64
set PATH=%QT_ANDROID_DIR%\bin;%ANDROID_NDK_ROOT%\prebuilt\windows-x86_64\bin;%JAVA_HOME%\bin;%PATH%

if not exist "%BUILDDIR%" mkdir "%BUILDDIR%"
pushd "%BUILDDIR%"
"%QT_ANDROID_DIR%\bin\qmake.exe" "%SRCDIR%\qgroundcontrol.pro" -spec android-clang GD_VARIANT=%VARIANT% "ANDROID_ABIS=arm64-v8a" CONFIG+=release > configure.log 2>&1
if errorlevel 1 (
  echo qmake falhou: veja %BUILDDIR%\configure.log
  popd & exit /b 1
)
"%ANDROID_NDK_ROOT%\prebuilt\windows-x86_64\bin\make.exe" -j%NUMBER_OF_PROCESSORS% > build.log 2>&1
set RC=%errorlevel%
echo %VARIANT%: build terminou com codigo %RC% (log em %BUILDDIR%\build.log)
popd
exit /b %RC%
