# ============================================================================
# POS-RoR Desktop - Test Ruby Portable
# ============================================================================
# Script para probar la aplicacion Ruby portable localmente

$ErrorActionPreference = "Stop"

Write-Host "=== Testing Ruby Portable Local ===" -ForegroundColor Cyan

# Verificar estructura
Write-Host "Verificando estructura de archivos..." -ForegroundColor Yellow

$RequiredFiles = @(
    @{ Path = "rails\app.rb"; Name = "Aplicacion Ruby" },
    @{ Path = "rails\start.rb"; Name = "Script de inicio" },
    @{ Path = "rails\start.bat"; Name = "Batch script" }
)

$AllGood = $true
foreach ($file in $RequiredFiles) {
    if (Test-Path $file.Path) {
        Write-Host "  [OK] $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] $($file.Name): $($file.Path)" -ForegroundColor Red
        $AllGood = $false
    }
}

if (!$AllGood) {
    Write-Host "Faltan archivos necesarios" -ForegroundColor Red
    exit 1
}

# Probar con Ruby del sistema
Write-Host "Probando con Ruby del sistema..." -ForegroundColor Yellow
try {
    $rubyVersion = & ruby --version 2>$null
    Write-Host "  Ruby encontrado: $rubyVersion" -ForegroundColor Green
    
    # Cambiar a directorio rails
    Push-Location rails
    
    Write-Host "  Iniciando aplicacion Ruby..." -ForegroundColor Yellow
    Write-Host "  (Presiona Ctrl+C para detener)" -ForegroundColor Gray
    Write-Host ""
    
    # Iniciar aplicacion
    & ruby start.rb
    
}
catch {
    Write-Host "  [ERROR] Ruby no disponible: $_" -ForegroundColor Red
    Write-Host "  Instalar Ruby desde: https://rubyinstaller.org/" -ForegroundColor Yellow
}
finally {
    if (Get-Location | Select-Object -ExpandProperty Path | Select-String "rails") {
        Pop-Location
    }
}

Write-Host ""
Write-Host "Para probar con Tauri:" -ForegroundColor White
Write-Host "  1. npm run tauri:dev" -ForegroundColor Gray
Write-Host "  2. npm run tauri:build" -ForegroundColor Gray
