# ============================================================================
# POS-RoR Desktop - Windows Resources Preparation Script
# ============================================================================
# Este script prepara todos los recursos necesarios para el empaquetado Windows:
# - Descarga Ruby portable
# - Configura SQLite
# - Instala gems en vendor/bundle
# - Prepara estructura de directorios

param(
    [string]$RubyVersion = "3.2.4-1",
    [switch]$SkipGems = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

# Colores para output
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

Write-Info "=== POS-RoR Desktop - Preparación de Recursos Windows ==="

# Paths principales
$Root = (Resolve-Path "$PSScriptRoot\..").Path
$RailsDir = Join-Path $Root "rails"
$RubyDir = Join-Path $RailsDir "ruby"
$SqliteDir = Join-Path $RailsDir "sqlite"
$VendorDir = Join-Path $RailsDir "vendor"

Write-Info "Directorio raíz: $Root"
Write-Info "Directorio Rails: $RailsDir"

# Crear directorios necesarios
$DirsToCreate = @($RailsDir, $RubyDir, $SqliteDir, $VendorDir)
foreach ($dir in $DirsToCreate) {
    if (!(Test-Path $dir)) {
        Write-Info "Creando directorio: $dir"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# ============================================================================
# 1. RUBY PORTABLE
# ============================================================================
Write-Info "=== Configurando Ruby Portable ==="

$RubyArchivePath = Join-Path $env:TEMP "ruby-portable.7z"
$RubyUrl = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$RubyVersion/ruby-$RubyVersion-x64-mingw32.7z"

# Verificar si Ruby ya está descargado
$RubyExePath = Join-Path $RubyDir "bin\ruby.exe"
if (Test-Path $RubyExePath) {
    Write-Info "Ruby portable ya existe, verificando versión..."
    $CurrentVersion = & $RubyExePath --version 2>$null
    if ($CurrentVersion -match $RubyVersion.Split('-')[0]) {
        Write-Info "Ruby $RubyVersion ya está instalado correctamente"
    }
    else {
        Write-Warning "Versión de Ruby incorrecta, descargando nueva versión..."
        Remove-Item -Recurse -Force $RubyDir
        New-Item -ItemType Directory -Force -Path $RubyDir | Out-Null
    }
}

if (!(Test-Path $RubyExePath)) {
    Write-Info "Descargando Ruby $RubyVersion desde GitHub..."
    
    try {
        # Usar TLS 1.2 para GitHub
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        Write-Info "URL: $RubyUrl"
        Invoke-WebRequest -Uri $RubyUrl -OutFile $RubyArchivePath -UseBasicParsing
        Write-Info "Descarga completada: $([math]::Round((Get-Item $RubyArchivePath).Length / 1MB, 2)) MB"
        
        # Extraer con 7zip (debe estar instalado en GitHub Actions)
        Write-Info "Extrayendo Ruby portable..."
        if (Get-Command "7z" -ErrorAction SilentlyContinue) {
            & 7z x $RubyArchivePath "-o$RubyDir" -y | Out-Null
        }
        elseif (Get-Command "C:\Program Files\7-Zip\7z.exe" -ErrorAction SilentlyContinue) {
            & "C:\Program Files\7-Zip\7z.exe" x $RubyArchivePath "-o$RubyDir" -y | Out-Null
        }
        else {
            throw "7-Zip no encontrado. Instalar con: choco install 7zip"
        }
        
        # Verificar extracción
        if (!(Test-Path $RubyExePath)) {
            throw "Error al extraer Ruby portable"
        }
        
        Write-Info "Ruby portable configurado correctamente"
        
        # Limpiar archivo temporal
        Remove-Item $RubyArchivePath -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Error "Error configurando Ruby portable: $_"
        exit 1
    }
}

# ============================================================================
# 2. SQLITE3 DLL
# ============================================================================
Write-Info "=== Configurando SQLite3 ==="

$SqliteDllPath = Join-Path $SqliteDir "sqlite3.dll"
if (!(Test-Path $SqliteDllPath)) {
    Write-Info "Descargando SQLite3 DLL..."
    
    try {
        $SqliteUrl = "https://www.sqlite.org/2024/sqlite-dll-win-x64-3460000.zip"
        $SqliteZipPath = Join-Path $env:TEMP "sqlite.zip"
        
        Invoke-WebRequest -Uri $SqliteUrl -OutFile $SqliteZipPath -UseBasicParsing
        Expand-Archive $SqliteZipPath -DestinationPath $SqliteDir -Force
        
        Write-Info "SQLite3 DLL configurado correctamente"
        Remove-Item $SqliteZipPath -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "No se pudo descargar SQLite3 DLL: $_"
        Write-Info "La gem sqlite3 puede incluir su propia DLL"
    }
}
else {
    Write-Info "SQLite3 DLL ya existe"
}

# ============================================================================
# 3. GEMS INSTALLATION
# ============================================================================
if (!$SkipGems) {
    Write-Info "=== Instalando Gems ==="
    
    # Configurar PATH para usar Ruby portable
    $env:PATH = "$RubyDir\bin;$env:PATH"
    
    # Verificar que Ruby funciona
    try {
        $RubyVersionOutput = & ruby --version
        Write-Info "Ruby version: $RubyVersionOutput"
    }
    catch {
        Write-Error "Error ejecutando Ruby portable: $_"
        exit 1
    }
    
    # Cambiar al directorio Rails
    Push-Location $RailsDir
    
    try {
        # Configurar Bundler para empaquetado
        Write-Info "Configurando Bundler..."
        & bundle config set --local deployment false
        & bundle config set --local path vendor/bundle
        & bundle config set --local without development:test
        & bundle config set --local jobs 4
        & bundle config set --local retry 3
        
        # Crear Gemfile específico para desktop si no existe
        $DesktopGemfile = Join-Path $RailsDir "Gemfile.desktop"
        if (!(Test-Path $DesktopGemfile)) {
            Write-Info "Creando Gemfile.desktop..."
            @"
# Gemfile específico para POS-RoR Desktop
source 'https://rubygems.org'

# Rails core
gem 'rails', '~> 8.0.1'
gem 'sqlite3', '~> 1.4'
gem 'puma', '>= 5.0'

# Asset pipeline
gem 'propshaft'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'jbuilder'

# Core functionality
gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Application specific
gem 'devise'
gem 'will_paginate', '~> 4.0.1'
gem 'friendly_id', '~> 5.5.1'
gem 'ransack'
gem 'to_words'
gem 'paranoia'
gem 'acts_as_tenant'
gem 'pundit'

# Barcode and QR
gem 'barby'
gem 'rqrcode'
gem 'chunky_png'

# Image processing
gem 'image_processing', '~> 1.14'
gem 'mini_magick', '~> 5.2'

# PDF generation
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Solid adapters for SQLite
gem 'solid_cache'
gem 'solid_queue'  
gem 'solid_cable'
"@ | Out-File -FilePath $DesktopGemfile -Encoding UTF8
        }
        
        # Instalar gems usando el Gemfile desktop
        Write-Info "Instalando gems (esto puede tomar varios minutos)..."
        $env:BUNDLE_GEMFILE = $DesktopGemfile
        & bundle install --verbose
        
        if ($LASTEXITCODE -ne 0) {
            throw "Error instalando gems"
        }
        
        Write-Info "Gems instalados correctamente en vendor/bundle"
        
        # Verificar gems críticos
        $CriticalGems = @('rails', 'sqlite3', 'puma', 'devise')
        foreach ($gem in $CriticalGems) {
            $gemCheck = & bundle exec gem list $gem
            if ($gemCheck -match $gem) {
                Write-Info "✓ Gem '$gem' instalado"
            }
            else {
                Write-Warning "✗ Gem '$gem' no encontrado"
            }
        }
    }
    catch {
        Write-Error "Error instalando gems: $_"
        exit 1
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Info "Omitiendo instalación de gems (--SkipGems especificado)"
}

# ============================================================================
# 4. VERIFICACIÓN FINAL
# ============================================================================
Write-Info "=== Verificación Final ==="

$RequiredPaths = @(
    @{ Path = $RubyExePath; Name = "Ruby executable" },
    @{ Path = (Join-Path $RubyDir "bin\bundle.bat"); Name = "Bundler" },
    @{ Path = (Join-Path $RailsDir "bin\start-rails.bat"); Name = "Start script" }
)

$AllGood = $true
foreach ($item in $RequiredPaths) {
    if (Test-Path $item.Path) {
        Write-Info "✓ $($item.Name): $($item.Path)"
    }
    else {
        Write-Error "✗ $($item.Name) no encontrado: $($item.Path)"
        $AllGood = $false
    }
}

if (!$SkipGems) {
    $VendorBundlePath = Join-Path $RailsDir "vendor\bundle"
    if (Test-Path $VendorBundlePath) {
        $GemCount = (Get-ChildItem $VendorBundlePath -Recurse -Filter "*.gem" -ErrorAction SilentlyContinue).Count
        Write-Info "✓ Vendor bundle: $GemCount gems empaquetados"
    }
    else {
        Write-Warning "✗ Vendor bundle no encontrado"
        $AllGood = $false
    }
}

# Mostrar tamaños de directorios
Write-Info "=== Información de Tamaños ==="
$Directories = @($RubyDir, $VendorDir, $SqliteDir)
foreach ($dir in $Directories) {
    if (Test-Path $dir) {
        $size = (Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 1)
        Write-Info "$(Split-Path $dir -Leaf): $sizeMB MB"
    }
}

if ($AllGood) {
    Write-Info "=== ✓ Preparación de recursos completada exitosamente ==="
    Write-Info "Los recursos están listos para el empaquetado con Tauri"
}
else {
    Write-Error "=== ✗ Errores durante la preparación ==="
    exit 1
}
