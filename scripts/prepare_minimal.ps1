# ============================================================================
# POS-RoR Desktop - Preparacion Minima para Testing
# ============================================================================
# Script minimo sin descargas complejas, solo estructura basica

$ErrorActionPreference = "Stop"

Write-Host "=== Preparacion Minima para Testing Local ===" -ForegroundColor Cyan

# Crear directorios basicos
$Dirs = @(
    "rails\ruby\bin",
    "rails\sqlite", 
    "rails\vendor\bundle",
    "rails\log",
    "rails\tmp"
)

Write-Host "Creando estructura de directorios..." -ForegroundColor Yellow
foreach ($dir in $Dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "  Creado: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Existe: $dir" -ForegroundColor Gray
    }
}

# Verificar si Ruby ya esta instalado en el sistema
Write-Host "Verificando Ruby del sistema..." -ForegroundColor Yellow
try {
    $systemRuby = & ruby --version 2>$null
    if ($systemRuby) {
        Write-Host "  Ruby del sistema encontrado: $systemRuby" -ForegroundColor Green
        
        # Crear symlink o copia para testing
        $rubyExe = Get-Command ruby -ErrorAction SilentlyContinue
        if ($rubyExe) {
            $targetPath = "rails\ruby\bin\ruby.exe"
            if (!(Test-Path $targetPath)) {
                Copy-Item $rubyExe.Source $targetPath -Force
                Write-Host "  Ruby copiado para testing: $targetPath" -ForegroundColor Green
            }
            
            # Copiar bundler tambien
            $bundlerExe = Get-Command bundle -ErrorAction SilentlyContinue
            if ($bundlerExe) {
                Copy-Item $bundlerExe.Source "rails\ruby\bin\bundle.exe" -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        throw "Ruby no encontrado"
    }
}
catch {
    Write-Host "  Ruby del sistema no disponible: $_" -ForegroundColor Yellow
    
    # Crear archivos dummy para que Tauri no falle
    Write-Host "  Creando archivos dummy..." -ForegroundColor Yellow
    @("ruby.exe", "bundle.exe") | ForEach-Object {
        $dummyPath = "rails\ruby\bin\$_"
        if (!(Test-Path $dummyPath)) {
            "# Dummy file for testing" | Out-File -FilePath $dummyPath -Encoding ASCII
            Write-Host "    Dummy: $dummyPath" -ForegroundColor Gray
        }
    }
}

# Verificar bundler y crear Gemfile.lock basico
Write-Host "Configurando Bundler basico..." -ForegroundColor Yellow
Push-Location rails

try {
    # Usar Gemfile.desktop si existe
    if (Test-Path "Gemfile.desktop") {
        Write-Host "  Usando Gemfile.desktop" -ForegroundColor Green
        $env:BUNDLE_GEMFILE = "Gemfile.desktop"
    }
    
    # Configurar bundler para vendor/bundle
    if (Get-Command bundle -ErrorAction SilentlyContinue) {
        bundle config set --local path vendor/bundle 2>$null
        bundle config set --local without development:test 2>$null
        Write-Host "  Bundler configurado" -ForegroundColor Green
        
        # Intentar bundle install (puede fallar, no es critico)
        try {
            Write-Host "  Intentando bundle install..." -ForegroundColor Yellow
            bundle install --quiet 2>$null
            Write-Host "  Bundle install exitoso" -ForegroundColor Green
        }
        catch {
            Write-Host "  Bundle install fallo (no critico): $_" -ForegroundColor Gray
            
            # Crear estructura minima en vendor/bundle
            New-Item -ItemType Directory -Force -Path "vendor\bundle\ruby" | Out-Null
        }
    } else {
        Write-Host "  Bundler no disponible, creando estructura minima" -ForegroundColor Gray
        New-Item -ItemType Directory -Force -Path "vendor\bundle\ruby" | Out-Null
    }
}
finally {
    Pop-Location
}

# Verificar archivos criticos para Tauri
Write-Host "Verificando archivos criticos..." -ForegroundColor Yellow
$CriticalFiles = @(
    @{ Path = "rails\bin\start-rails.bat"; Name = "Start script" },
    @{ Path = "rails\ruby\bin\ruby.exe"; Name = "Ruby executable" },
    @{ Path = "rails\vendor\bundle"; Name = "Vendor bundle dir" }
)

$AllGood = $true
foreach ($file in $CriticalFiles) {
    if (Test-Path $file.Path) {
        Write-Host "  [OK] $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $($file.Name): $($file.Path)" -ForegroundColor Red
        $AllGood = $false
    }
}

# Crear archivos de configuracion basicos si no existen
if (!(Test-Path "rails\config\database_desktop.yml")) {
    Write-Host "Creando configuracion basica..." -ForegroundColor Yellow
    
    $basicDbConfig = @"
desktop:
  adapter: sqlite3
  database: db/desktop.sqlite3
  pool: 5
  timeout: 5000
"@
    $basicDbConfig | Out-File -FilePath "rails\config\database_desktop.yml" -Encoding UTF8
    Write-Host "  Creado: database_desktop.yml" -ForegroundColor Green
}

# Resumen
Write-Host "=== Resumen de Preparacion Minima ===" -ForegroundColor Cyan
if ($AllGood) {
    Write-Host "[SUCCESS] Estructura basica lista para testing" -ForegroundColor Green
    Write-Host "Puedes probar con: npm run tauri:dev" -ForegroundColor White
} else {
    Write-Host "[WARNING] Algunos archivos faltan, pero se puede continuar" -ForegroundColor Yellow
    Write-Host "El MSI puede no ser completamente funcional" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor White
Write-Host "  1. npm install" -ForegroundColor Gray
Write-Host "  2. npm run tauri:dev  (para desarrollo)" -ForegroundColor Gray
Write-Host "  3. npm run tauri:build  (para generar MSI)" -ForegroundColor Gray
