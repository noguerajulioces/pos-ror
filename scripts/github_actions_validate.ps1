# ============================================================================
# POS-RoR Desktop - GitHub Actions MSI Validation Script
# ============================================================================
# Script simplificado para validar el MSI generado

$ErrorActionPreference = "Stop"

Write-Host "=== Validación básica del MSI ===" -ForegroundColor Cyan

$MsiPath = Get-ChildItem -Path "src-tauri\target\release\bundle\msi\*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1

if (!$MsiPath) {
    Write-Host "✗ No se encontró archivo MSI para validar" -ForegroundColor Red
    exit 1
}

# Verificar que es un MSI válido
try {
    $Installer = New-Object -ComObject WindowsInstaller.Installer
    $Database = $Installer.OpenDatabase($MsiPath.FullName, 0)
    Write-Host "✓ MSI es válido y se puede abrir" -ForegroundColor Green
    $Database = $null
    $Installer = $null
} catch {
    Write-Host "✗ Error validando MSI: $_" -ForegroundColor Red
    exit 1
}

# Verificar tamaño mínimo (debe ser > 50MB con Ruby incluido)
$MinSizeMB = 50
$ActualSizeMB = [math]::Round($MsiPath.Length / 1MB, 1)

if ($ActualSizeMB -gt $MinSizeMB) {
    Write-Host "✓ Tamaño del MSI es apropiado: $ActualSizeMB MB" -ForegroundColor Green
} else {
    Write-Host "✗ MSI demasiado pequeño: $ActualSizeMB MB (mínimo: $MinSizeMB MB)" -ForegroundColor Red
    Write-Host "Esto podría indicar que Ruby portable no se incluyó correctamente" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Validación del MSI completada exitosamente" -ForegroundColor Green
