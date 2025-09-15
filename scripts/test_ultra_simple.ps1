# ============================================================================
# POS-RoR Desktop - Test ULTRA SIMPLE
# ============================================================================
# Version mas basica posible, solo frontend estatico

$ErrorActionPreference = "Stop"

Write-Host "=== Test ULTRA SIMPLE ===" -ForegroundColor Cyan

# Verificar archivos minimos
Write-Host "Verificando archivos minimos..." -ForegroundColor Yellow

$RequiredFiles = @(
    @{ Path = "dist\index.html"; Name = "Frontend HTML" },
    @{ Path = "src-tauri\tauri.conf.json"; Name = "Tauri config" },
    @{ Path = "src-tauri\src\main.rs"; Name = "Main Rust" }
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
    Write-Host "Faltan archivos criticos" -ForegroundColor Red
    exit 1
}

# Verificar Tauri CLI
Write-Host "Verificando Tauri CLI..." -ForegroundColor Yellow
try {
    $tauriVersion = & tauri --version 2>$null
    Write-Host "  [OK] Tauri CLI: $tauriVersion" -ForegroundColor Green
}
catch {
    Write-Host "  [ERROR] Tauri CLI no encontrado" -ForegroundColor Red
    Write-Host "  Instalar: npm install -g @tauri-apps/cli" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[SUCCESS] Todo listo para build ultra simple" -ForegroundColor Green
Write-Host ""
Write-Host "Comandos disponibles:" -ForegroundColor White
Write-Host "  tauri dev      - Desarrollo" -ForegroundColor Gray
Write-Host "  tauri build    - Build MSI" -ForegroundColor Gray
Write-Host ""
Write-Host "Este build generara un MSI con solo frontend estatico." -ForegroundColor Yellow
Write-Host "Ruby se agregara en futuras versiones." -ForegroundColor Yellow
