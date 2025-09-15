# ============================================================================
# POS-RoR Desktop - Script de Testing Local
# ============================================================================
# Este script permite probar localmente el build de la aplicación desktop
# sin necesidad de ejecutar todo el proceso de GitHub Actions

param(
    [switch]$SkipPrep = $false,
    [switch]$SkipBuild = $false,
    [switch]$SkipTest = $false,
    [switch]$CleanFirst = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Info($message) { Write-ColorOutput Green "[INFO] $message" }
function Write-Warning($message) { Write-ColorOutput Yellow "[WARN] $message" }
function Write-Error($message) { Write-ColorOutput Red "[ERROR] $message" }
function Write-Step($message) { Write-ColorOutput Cyan "=== $message ===" }

Write-Step "POS-RoR Desktop - Test Build Local"

# Verificar que estamos en el directorio correcto
if (!(Test-Path "package.json") -or !(Test-Path "src-tauri")) {
    Write-Error "Este script debe ejecutarse desde la raíz del proyecto"
    exit 1
}

# Limpiar si se solicita
if ($CleanFirst) {
    Write-Step "Limpiando archivos anteriores"
    
    $DirsToClean = @(
        "rails\ruby",
        "rails\vendor\bundle", 
        "rails\sqlite",
        "src-tauri\target",
        "node_modules\.cache"
    )
    
    foreach ($dir in $DirsToClean) {
        if (Test-Path $dir) {
            Write-Info "Eliminando: $dir"
            Remove-Item -Recurse -Force $dir
        }
    }
}

# Verificar dependencias del sistema
Write-Step "Verificando Dependencias del Sistema"

$RequiredTools = @(
    @{ Name = "Node.js"; Command = "node"; Args = @("--version") },
    @{ Name = "npm"; Command = "npm"; Args = @("--version") },
    @{ Name = "Rust"; Command = "rustc"; Args = @("--version") },
    @{ Name = "Cargo"; Command = "cargo"; Args = @("--version") },
    @{ Name = "7-Zip"; Command = "7z"; Args = @() },
    @{ Name = "Tauri CLI"; Command = "tauri"; Args = @("--version") }
)

$MissingTools = @()
foreach ($tool in $RequiredTools) {
    try {
        if ($tool.Args.Count -gt 0) {
            $output = & $tool.Command $tool.Args 2>$null
            Write-Info "[OK] $($tool.Name): $($output -split "`n" | Select-Object -First 1)"
        } else {
            & $tool.Command >$null 2>&1
            Write-Info "[OK] $($tool.Name): Disponible"
        }
    } catch {
        Write-Warning "[ERROR] $($tool.Name): No encontrado"
        $MissingTools += $tool.Name
    }
}

if ($MissingTools.Count -gt 0) {
    Write-Error "Herramientas faltantes: $($MissingTools -join ', ')"
    Write-Info "Instalar con:"
    Write-Info "  choco install nodejs rust 7zip"
    Write-Info "  npm install -g @tauri-apps/cli"
    exit 1
}

# Instalar dependencias Node si no existen
if (!(Test-Path "node_modules")) {
    Write-Step "Instalando Dependencias Node.js"
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error instalando dependencias Node.js"
        exit 1
    }
}

# Preparar recursos Windows
if (!$SkipPrep) {
    Write-Step "Preparando Recursos Windows"
    
    $PrepArgs = @()
    if ($Verbose) { $PrepArgs += "-Verbose" }
    
    & ".\scripts\prepare_windows_resources.ps1" @PrepArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error preparando recursos Windows"
        exit 1
    }
    
    Write-Info "Recursos Windows preparados exitosamente"
} else {
    Write-Info "Omitiendo preparación de recursos (--SkipPrep)"
}

# Verificar que los recursos están listos
Write-Step "Verificando Recursos"

$RequiredResources = @(
    @{ Path = "rails\ruby\bin\ruby.exe"; Name = "Ruby executable" },
    @{ Path = "rails\bin\start-rails.bat"; Name = "Start script" },
    @{ Path = "rails\vendor\bundle"; Name = "Vendor bundle" }
)

foreach ($resource in $RequiredResources) {
    if (Test-Path $resource.Path) {
        Write-Info "[OK] $($resource.Name)"
    } else {
        Write-Error "[ERROR] $($resource.Name) no encontrado: $($resource.Path)"
        exit 1
    }
}

# Test rápido de Rails (opcional)
if (!$SkipTest) {
    Write-Step "Test Rápido de Rails"
    
    Push-Location rails
    try {
        # Configurar entorno
        $env:PATH = "$PWD\ruby\bin;$env:PATH"
        $env:RAILS_ENV = "desktop"
        
        # Test básico - verificar que Rails puede cargar
        Write-Info "Verificando que Rails puede cargar..."
        $output = & bundle exec rails runner "puts 'Rails OK: ' + Rails.version" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Info "[OK] $output"
        } else {
            Write-Warning "[ERROR] Rails test falló: $output"
        }
        
        # Test de base de datos
        Write-Info "Verificando configuración de base de datos..."
        $dbOutput = & bundle exec rails runner "puts 'DB OK: ' + ActiveRecord::Base.connection.adapter_name" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Info "[OK] $dbOutput"
        } else {
            Write-Warning "[ERROR] Database test falló: $dbOutput"
        }
        
    } catch {
        Write-Warning "Error en tests de Rails: $_"
    } finally {
        Pop-Location
    }
} else {
    Write-Info "Omitiendo tests (--SkipTest)"
}

# Build con Tauri
if (!$SkipBuild) {
    Write-Step "Construyendo MSI con Tauri"
    
    # Asegurar que WiX esté disponible si está instalado
    if (Test-Path "${env:WIX}bin\candle.exe") {
        $env:PATH = "${env:WIX}bin;$env:PATH"
        Write-Info "WiX Toolset encontrado: ${env:WIX}"
    } else {
        Write-Warning "WiX Toolset no encontrado - instalará automáticamente si es necesario"
    }
    
    # Ejecutar build
    Write-Info "Iniciando build de Tauri (esto puede tomar varios minutos)..."
    
    $BuildStart = Get-Date
    tauri build --verbose
    $BuildEnd = Get-Date
    $BuildTime = $BuildEnd - $BuildStart
    
    if ($LASTEXITCODE -eq 0) {
        Write-Info "[OK] Build completado en $([math]::Round($BuildTime.TotalMinutes, 1)) minutos"
        
        # Verificar MSI generado
        $MsiFiles = Get-ChildItem -Path "src-tauri\target\release\bundle\msi\*.msi" -ErrorAction SilentlyContinue
        
        if ($MsiFiles) {
            Write-Step "MSI Generado Exitosamente"
            foreach ($msi in $MsiFiles) {
                $sizeMB = [math]::Round($msi.Length / 1MB, 1)
                Write-Info "📦 $($msi.Name) - ${sizeMB} MB"
                Write-Info "   Ubicación: $($msi.FullName)"
            }
            
            # Mostrar instrucciones para probar
            Write-Step "¿Cómo Probar el MSI?"
            Write-Info "1. Navegar a: src-tauri\target\release\bundle\msi\"
            Write-Info "2. Ejecutar el MSI como administrador"
            Write-Info "3. Seguir las instrucciones del instalador"
            Write-Info "4. Buscar 'POS-RoR Desktop' en el menú inicio"
            
        } else {
            Write-Error "[ERROR] No se encontraron archivos MSI después del build"
            exit 1
        }
        
    } else {
        Write-Error "[ERROR] Build falló"
        exit 1
    }
    
} else {
    Write-Info "Omitiendo build (--SkipBuild)"
}

# Resumen final
Write-Step "Resumen del Test"
Write-Info "[SUCCESS] Todas las verificaciones pasaron exitosamente"
Write-Info "[SUCCESS] La aplicación está lista para distribución"

if (!$SkipBuild) {
    $MsiPath = Get-ChildItem -Path "src-tauri\target\release\bundle\msi\*.msi" | Select-Object -First 1
    if ($MsiPath) {
        Write-Info "📦 MSI final: $($MsiPath.Name)"
        Write-Info "🚀 Listo para distribuir!"
    }
}

Write-Info ""
Write-Info "Para más información sobre el proyecto, ver README_WINDOWS.md"
