# ============================================================================
# POS-RoR Desktop - GitHub Actions Build Script
# ============================================================================
# Script simplificado para el build de Tauri en GitHub Actions

$ErrorActionPreference = "Stop"

Write-Host "=== Construyendo MSI con Tauri ===" -ForegroundColor Cyan

# Asegurar que WiX esté en PATH
if ($env:WIX) {
    $env:PATH = "$env:WIX\bin;$env:PATH"
    Write-Host "WiX Toolset configurado: $env:WIX" -ForegroundColor Green
} else {
    Write-Host "WiX Toolset no encontrado en variable de entorno" -ForegroundColor Yellow
}

# Build con Tauri
Write-Host "Iniciando build de Tauri..." -ForegroundColor Green
tauri build --verbose

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error durante el build de Tauri" -ForegroundColor Red
    exit 1
}

# Verificar que el MSI se creó
$MsiPath = Get-ChildItem -Path "src-tauri\target\release\bundle\msi\*.msi" -ErrorAction SilentlyContinue

if ($MsiPath) {
    $MsiSize = [math]::Round($MsiPath.Length / 1MB, 1)
    Write-Host "✓ MSI creado exitosamente: $($MsiPath.Name) ($MsiSize MB)" -ForegroundColor Green
    
    # Mostrar información del MSI
    Write-Host "Información del MSI:" -ForegroundColor Yellow
    Write-Host "  Nombre: $($MsiPath.Name)" -ForegroundColor White
    Write-Host "  Tamaño: $MsiSize MB" -ForegroundColor White
    Write-Host "  Ruta: $($MsiPath.FullName)" -ForegroundColor White
} else {
    Write-Host "✗ No se encontró el archivo MSI" -ForegroundColor Red
    
    # Mostrar contenido del directorio de salida para debug
    Write-Host "Contenido de src-tauri\target\release\bundle:" -ForegroundColor Yellow
    if (Test-Path "src-tauri\target\release\bundle") {
        Get-ChildItem -Path "src-tauri\target\release\bundle" -Recurse -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime
    } else {
        Write-Host "Directorio bundle no existe" -ForegroundColor Red
    }
    
    exit 1
}
