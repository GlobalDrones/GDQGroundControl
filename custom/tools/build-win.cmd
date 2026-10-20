@echo off
rem Compila uma variante para Windows (desenvolvimento).
rem Uso: custom\tools\build-win.cmd <gd25|gd30|gd60|gd70|gd150> [pasta-de-build]
rem Pasta padrão: ..\build-<variante>-win, ao lado do repositório. Log em build.log.
rem Caminhos ajustáveis por variável de ambiente: VCVARS, QT_DIR, GST_ROOT, JOM.
setlocal
if "%~1"=="" (
  echo Uso: %~nx0 ^<gd25^|gd30^|gd60^|gd70^|gd150^> [pasta-de-build]
  exit /b 1
)
set VARIANT=%~1
set SRCDIR=%~dp0..\..
if not "%~2"=="" (set BUILDDIR=%~2) else (set BUILDDIR=%SRCDIR%\..\build-%VARIANT%-win)
if not defined VCVARS set VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
if not defined QT_DIR set QT_DIR=C:\Qt\5.15.2\msvc2019_64
if not defined GST_ROOT set GST_ROOT=C:/Program Files/gstreamer/1.0/msvc_x86_64
if not defined JOM set JOM=C:\Qt\Tools\QtCreator\bin\jom\jom.exe

call "%VCVARS%" >nul 2>&1 || exit /b 1
if not exist "%BUILDDIR%" mkdir "%BUILDDIR%"
pushd "%BUILDDIR%"
"%QT_DIR%\bin\qmake.exe" "%SRCDIR%\qgroundcontrol.pro" GD_VARIANT=%VARIANT% "GST_ROOT=%GST_ROOT%" CONFIG+=release > configure.log 2>&1
if errorlevel 1 (
  echo qmake falhou: veja %BUILDDIR%\configure.log
  popd & exit /b 1
)
"%JOM%" -j%NUMBER_OF_PROCESSORS% > build.log 2>&1
set RC=%errorlevel%
echo %VARIANT%: build terminou com codigo %RC% (log em %BUILDDIR%\build.log)
popd
exit /b %RC%
