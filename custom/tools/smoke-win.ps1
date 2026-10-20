# Teste de fumaça (Windows): abre o app sem janela, conecta um veículo ArduPilot
# simulado (fake-vehicle.py, precisa de pymavlink), salva uma imagem da tela de
# voo e coleta os avisos de QML do log.
#
#   pwsh custom\tools\smoke-win.ps1 -Variant gd60 [-BuildDir ..\build-gd60-win]
#
# As configurações do QGC deste PC (%APPDATA%\QGroundControl.org) são salvas antes
# e restauradas depois: o GD usa o mesmo arquivo "QGroundControl Daily.ini".
# Saída: <pasta-de-build>\smoke.log e smoke.png
param(
    [Parameter(Mandatory = $true)][string]$Variant,
    [string]$BuildDir,
    [int]$Seconds = 45,
    [int]$ShotDelay = 30
)

$tools    = $PSScriptRoot
if (-not $BuildDir) { $BuildDir = Join-Path $tools "..\..\..\build-$Variant-win" }
$BuildDir = (Resolve-Path $BuildDir).Path
$root     = $BuildDir
$staging  = Join-Path $BuildDir "staging"
$exe      = Get-ChildItem $staging -Filter *.exe | Where-Object { $_.Name -notlike 'vc_redist*' } | Select-Object -First 1
if (-not $exe) { throw "Executável não encontrado em $staging" }

$settings = Join-Path $env:APPDATA 'QGroundControl.org'
$backup   = Join-Path $env:TEMP "gd-smoke-settings-$PID\QGroundControl.org"
New-Item -ItemType Directory -Force (Split-Path $backup) | Out-Null
if (Test-Path $settings) { Copy-Item $settings $backup -Recurse }
else { New-Item -ItemType Directory -Force $settings | Out-Null; New-Item -ItemType Directory -Force $backup | Out-Null }

# A porta 14550 pode estar ocupada por outra GCS aberta no PC (ex.: Mission
# Planner). O teste usa a 14650 na autoconexão UDP do QGC.
$udpPort = 14650
foreach ($ini in @('QGroundControl Daily.ini', 'GD60_QGC Daily.ini')) {
    Add-Content -Path (Join-Path $settings $ini) -Value "`r`n[LinkManager]`r`nudpListenPort=$udpPort`r`n" -Encoding UTF8
}

$log = Join-Path $root "smoke.log"
$env:QT_FORCE_STDERR_LOGGING = '1'
$env:QT_QPA_PLATFORM         = 'offscreen'
$qtDir = if ($env:QT_DIR) { $env:QT_DIR } else { 'C:\Qt\5.15.2\msvc2019_64' }
$env:QT_QPA_PLATFORM_PLUGIN_PATH = Join-Path $qtDir 'plugins\platforms'
$env:QT_QUICK_BACKEND        = 'software'
$env:QT_LOGGING_RULES        = 'qt.qml.binding.removal.info=false'
$env:GD_SCREENSHOT          = Join-Path $root "smoke.png"
$env:GD_SCREENSHOT_DELAY    = [string]($ShotDelay * 1000)
if (Test-Path $env:GD_SCREENSHOT) { Remove-Item $env:GD_SCREENSHOT }

$p = Start-Process -FilePath $exe.FullName -ArgumentList '--logging:LinkManagerLog,MultiVehicleManagerLog,VehicleLog' -WorkingDirectory $staging -PassThru `
        -RedirectStandardError $log -RedirectStandardOutput "$log.out"
# Veículo simulado para carregar barra superior e painéis com veículo. Só começa
# depois que o QGC já abriu a porta UDP.
Start-Sleep -Seconds 12
$fake = Start-Process -FilePath python -ArgumentList @("$tools\fake-vehicle.py", ($Seconds - 17), $udpPort) -PassThru -WindowStyle Hidden -RedirectStandardOutput "$log.fake"
Start-Sleep -Seconds ($Seconds - 12)
if (-not $fake.HasExited) { Stop-Process -Id $fake.Id -Force }
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
Start-Sleep -Seconds 2

# Restaura as configurações originais
if (Test-Path $settings) { Remove-Item $settings -Recurse -Force }
if ((Get-ChildItem $backup -Force | Measure-Object).Count -gt 0) { Copy-Item $backup $settings -Recurse }

Write-Output "Exit: $($p.ExitCode)  log: $log"
Select-String -Path $log -Pattern 'qml|QML|ReferenceError|TypeError|is not a type|not installed|Cannot assign|Unable to assign|file not found|No such file' |
    Select-Object -First 80 | ForEach-Object { $_.Line }
