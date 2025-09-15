# ============================================================================
# POS-RoR Desktop - Encoding Check Script
# ============================================================================
# Script para verificar que no hay caracteres Unicode problematicos
# en los scripts de PowerShell

$ErrorActionPreference = "Stop"

Write-Host "=== Verificando encoding de scripts PowerShell ===" -ForegroundColor Cyan

$ScriptsToCheck = @(
    "scripts\prepare_windows_resources.ps1",
    "scripts\github_actions_prepare.ps1",
    "scripts\github_actions_build.ps1", 
    "scripts\github_actions_validate.ps1",
    "scripts\test_desktop_build.ps1"
)

$ProblematicChars = @(
    @{ Char = "✓"; Name = "Check mark" },
    @{ Char = "✗"; Name = "X mark" },
    @{ Char = "✅"; Name = "Check mark button" },
    @{ Char = "❌"; Name = "Cross mark" },
    @{ Char = "🚀"; Name = "Rocket" },
    @{ Char = "📦"; Name = "Package" },
    @{ Char = "🔧"; Name = "Wrench" },
    @{ Char = "ñ"; Name = "Spanish n" },
    @{ Char = "á"; Name = "Accented a" },
    @{ Char = "é"; Name = "Accented e" },
    @{ Char = "í"; Name = "Accented i" },
    @{ Char = "ó"; Name = "Accented o" },
    @{ Char = "ú"; Name = "Accented u" }
)

$AllClean = $true

foreach ($scriptPath in $ScriptsToCheck) {
    if (Test-Path $scriptPath) {
        Write-Host "Verificando: $scriptPath" -ForegroundColor Yellow
        
        $content = Get-Content $scriptPath -Raw -Encoding UTF8
        
        foreach ($char in $ProblematicChars) {
            if ($content -match [regex]::Escape($char.Char)) {
                Write-Host "  [WARNING] Encontrado '$($char.Char)' ($($char.Name))" -ForegroundColor Red
                $AllClean = $false
            }
        }
        
        if ($AllClean) {
            Write-Host "  [OK] Limpio" -ForegroundColor Green
        }
    } else {
        Write-Host "[WARNING] Script no encontrado: $scriptPath" -ForegroundColor Yellow
    }
}

if ($AllClean) {
    Write-Host "[SUCCESS] Todos los scripts estan limpios de caracteres problematicos" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[ERROR] Se encontraron caracteres problematicos en algunos scripts" -ForegroundColor Red
    Write-Host "Estos caracteres pueden causar errores de parsing en GitHub Actions" -ForegroundColor Yellow
    exit 1
}
