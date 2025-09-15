# ============================================================================
# POS-RoR Desktop - GitHub Actions MSI Validation Script
# ============================================================================
# Script simplificado para validar el MSI generado

$ErrorActionPreference = "Stop"

Write-Host "=== Validacion basica del MSI ===" -ForegroundColor Cyan

$MsiPath = Get-ChildItem -Path "src-tauri\target\release\bundle\msi\*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1

if (!$MsiPath) {
    Write-Host "[ERROR] No se encontro archivo MSI para validar" -ForegroundColor Red
    exit 1
}

# Verificar que es un MSI valido
try {
    $Installer = New-Object -ComObject WindowsInstaller.Installer
    $Database = $Installer.OpenDatabase($MsiPath.FullName, 0)
    Write-Host "[OK] MSI es valido y se puede abrir" -ForegroundColor Green
    $Database = $null
    $Installer = $null
} catch {
    Write-Host "[ERROR] Error validando MSI: $_" -ForegroundColor Red
    exit 1
}

# Verificar tamano minimo (debe ser > 50MB con Ruby incluido)
$MinSizeMB = 50
$ActualSizeMB = [math]::Round($MsiPath.Length / 1MB, 1)

if ($ActualSizeMB -gt $MinSizeMB) {
    Write-Host "[OK] Tamano del MSI es apropiado: $ActualSizeMB MB" -ForegroundColor Green
} else {
    Write-Host "[ERROR] MSI demasiado pequeno: $ActualSizeMB MB (minimo: $MinSizeMB MB)" -ForegroundColor Red
    Write-Host "Esto podria indicar que Ruby portable no se incluyo correctamente" -ForegroundColor Yellow
    exit 1
}

Write-Host "[SUCCESS] Validacion del MSI completada exitosamente" -ForegroundColor Green
