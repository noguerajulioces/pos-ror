# ============================================================================
# POS-RoR Desktop - Preparacion ULTRA BASICA
# ============================================================================
# Version mas simple posible solo para generar MSI distribuible

$ErrorActionPreference = "Stop"

Write-Host "=== Preparacion ULTRA BASICA para Distribucion ===" -ForegroundColor Cyan

# 1. Verificar que Tauri CLI esta instalado
Write-Host "Verificando Tauri CLI..." -ForegroundColor Yellow
try {
    $tauriVersion = & tauri --version 2>$null
    Write-Host "  Tauri CLI: $tauriVersion" -ForegroundColor Green
}
catch {
    Write-Host "  [ERROR] Tauri CLI no encontrado" -ForegroundColor Red
    Write-Host "  Instalar con: npm install -g @tauri-apps/cli" -ForegroundColor Yellow
    exit 1
}

# 2. Verificar estructura basica
Write-Host "Verificando estructura de archivos..." -ForegroundColor Yellow

$RequiredFiles = @(
    @{ Path = "dist\index.html"; Name = "Frontend HTML" },
    @{ Path = "src-tauri\tauri.conf.json"; Name = "Tauri config" },
    @{ Path = "src-tauri\Cargo.toml"; Name = "Cargo config" },
    @{ Path = "src-tauri\src\main.rs"; Name = "Main Rust file" }
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
    Write-Host "Faltan archivos criticos para el build" -ForegroundColor Red
    exit 1
}

# 3. Crear estructura minima rails (solo para incluir en MSI)
Write-Host "Creando estructura Rails minima..." -ForegroundColor Yellow
if (!(Test-Path "rails")) {
    New-Item -ItemType Directory -Force -Path "rails" | Out-Null
}

$RailsPlaceholder = @"
# POS-RoR Rails Application
# Esta es la version basica para distribucion
# La aplicacion Rails completa se incluira en futuras versiones

Aplicacion: POS-RoR Desktop
Version: 1.0.0 - Build Basico
Fecha: $(Get-Date)
"@

$RailsPlaceholder | Out-File -FilePath "rails\README.txt" -Encoding UTF8
Write-Host "  Creado: rails\README.txt" -ForegroundColor Green

# 4. Verificar que podemos hacer build
Write-Host "Verificando configuracion de build..." -ForegroundColor Yellow
try {
    # Cambiar al directorio src-tauri para verificar
    Push-Location "src-tauri"
    
    # Verificar que Cargo.toml es valido
    $cargoCheck = & cargo check --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Configuracion Rust valida" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Posibles issues en Cargo.toml: $cargoCheck" -ForegroundColor Yellow
    }
    
    Pop-Location
}
catch {
    Write-Host "  [WARN] No se pudo verificar configuracion Rust: $_" -ForegroundColor Yellow
    if (Get-Location | Select-Object -ExpandProperty Path | Select-String "src-tauri") {
        Pop-Location
    }
}

# 5. Resumen
Write-Host "=== Resumen ULTRA BASICO ===" -ForegroundColor Cyan
Write-Host "[SUCCESS] Estructura minima lista para distribucion" -ForegroundColor Green
Write-Host ""
Write-Host "Para generar MSI:" -ForegroundColor White
Write-Host "  1. npm run tauri:build" -ForegroundColor Gray
Write-Host "  2. El MSI estara en: src-tauri\target\release\bundle\msi\" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTA: Este es un build basico solo para distribucion." -ForegroundColor Yellow
Write-Host "La funcionalidad completa se agregara en futuras versiones." -ForegroundColor Yellow
