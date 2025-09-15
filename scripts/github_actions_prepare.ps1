# ============================================================================
# POS-RoR Desktop - GitHub Actions Preparation Script
# ============================================================================
# Script simplificado para GitHub Actions que evita problemas de sintaxis
# complejos en el workflow YAML

$ErrorActionPreference = "Stop"

Write-Host "=== Preparando recursos para Windows (GitHub Actions) ===" -ForegroundColor Cyan

# Ejecutar script principal de preparación
Write-Host "Ejecutando script principal de preparación..." -ForegroundColor Green
& "$PSScriptRoot\prepare_windows_resources.ps1" -Verbose

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en la preparación de recursos" -ForegroundColor Red
    exit 1
}

Write-Host "Verificando recursos preparados..." -ForegroundColor Yellow

# Verificar archivos críticos
$RequiredPaths = @(
    "rails\ruby\bin\ruby.exe",
    "rails\bin\start-rails.bat", 
    "rails\vendor\bundle"
)

$AllGood = $true
foreach ($path in $RequiredPaths) {
    if (Test-Path $path) {
        Write-Host "✓ $path" -ForegroundColor Green
    } else {
        Write-Host "✗ $path - NO ENCONTRADO" -ForegroundColor Red
        $AllGood = $false
    }
}

if (!$AllGood) {
    Write-Host "Faltan recursos críticos" -ForegroundColor Red
    exit 1
}

# Mostrar tamaños (versión simplificada)
try {
    $RubySize = [math]::Round(((Get-ChildItem rails\ruby -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB), 1)
    $VendorSize = [math]::Round(((Get-ChildItem rails\vendor -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB), 1)
    
    Write-Host "Ruby portable: $RubySize MB" -ForegroundColor Cyan
    Write-Host "Vendor bundle: $VendorSize MB" -ForegroundColor Cyan
}
catch {
    Write-Host "No se pudo calcular tamaños (no crítico)" -ForegroundColor Yellow
}

Write-Host "✅ Preparación completada exitosamente" -ForegroundColor Green
