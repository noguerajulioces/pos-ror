# ============================================================================
# POS-RoR Desktop - Ruby Portable Download Script
# ============================================================================
# Script especializado para descargar Ruby portable con multiples metodos

param(
    [string]$RubyVersion = "3.2.4-1",
    [string]$TargetDir = "rails\ruby",
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

function Write-Info($message) { Write-Host "[INFO] $message" -ForegroundColor Green }
function Write-Warning($message) { Write-Host "[WARN] $message" -ForegroundColor Yellow }
function Write-Error($message) { Write-Host "[ERROR] $message" -ForegroundColor Red }

Write-Info "=== Descargando Ruby Portable $RubyVersion ==="

# URLs y paths
$RubyUrl = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$RubyVersion/ruby-$RubyVersion-x64-mingw32.7z"
$TempFile = Join-Path $env:TEMP "ruby-portable.7z"
$RubyExePath = Join-Path $TargetDir "bin\ruby.exe"

# Crear directorio objetivo
if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# Verificar si ya esta descargado
if (Test-Path $RubyExePath) {
    Write-Info "Ruby portable ya existe en $TargetDir"
    exit 0
}

Write-Info "URL: $RubyUrl"
Write-Info "Archivo temporal: $TempFile"

# Metodo 1: PowerShell WebClient (mas confiable)
function Download-WithWebClient {
    Write-Info "Metodo 1: Usando WebClient..."
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        [Net.ServicePointManager]::DefaultConnectionLimit = 4
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "POS-RoR-Desktop-Build/1.0")
        
        # Progress callback
        Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
            $percent = $Event.SourceEventArgs.ProgressPercentage
            if ($percent % 10 -eq 0) {  # Mostrar cada 10%
                Write-Host "  Progreso: $percent%" -ForegroundColor Cyan
            }
        } | Out-Null
        
        $webClient.DownloadFile($RubyUrl, $TempFile)
        $webClient.Dispose()
        
        return $true
    }
    catch {
        Write-Warning "WebClient fallo: $_"
        if ($webClient) { $webClient.Dispose() }
        return $false
    }
}

# Metodo 2: Invoke-WebRequest con configuracion robusta
function Download-WithInvokeWebRequest {
    Write-Info "Metodo 2: Usando Invoke-WebRequest..."
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $progressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        
        Invoke-WebRequest -Uri $RubyUrl -OutFile $TempFile -UseBasicParsing -TimeoutSec 300 -UserAgent "POS-RoR-Desktop-Build/1.0"
        
        $global:ProgressPreference = $progressPreference
        return $true
    }
    catch {
        Write-Warning "Invoke-WebRequest fallo: $_"
        return $false
    }
}

# Metodo 3: curl (si esta disponible)
function Download-WithCurl {
    Write-Info "Metodo 3: Usando curl..."
    
    try {
        if (Get-Command curl -ErrorAction SilentlyContinue) {
            & curl -L -o $TempFile $RubyUrl --user-agent "POS-RoR-Desktop-Build/1.0" --connect-timeout 30 --max-time 600 --retry 2 --retry-delay 5
            
            if ($LASTEXITCODE -eq 0) {
                return $true
            } else {
                Write-Warning "curl fallo con codigo $LASTEXITCODE"
                return $false
            }
        } else {
            Write-Warning "curl no disponible"
            return $false
        }
    }
    catch {
        Write-Warning "curl fallo: $_"
        return $false
    }
}

# Intentar descarga con multiples metodos
$Downloaded = $false
$Methods = @(
    { Download-WithWebClient },
    { Download-WithInvokeWebRequest },
    { Download-WithCurl }
)

foreach ($method in $Methods) {
    # Limpiar archivo anterior si existe
    if (Test-Path $TempFile) {
        Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
    }
    
    if (& $method) {
        # Verificar que el archivo se descargo completamente
        if (Test-Path $TempFile) {
            $fileSize = (Get-Item $TempFile).Length
            if ($fileSize -gt 10MB) {
                Write-Info "Descarga exitosa: $([math]::Round($fileSize / 1MB, 2)) MB"
                $Downloaded = $true
                break
            } else {
                Write-Warning "Archivo descargado parece incompleto: $([math]::Round($fileSize / 1MB, 2)) MB"
            }
        }
    }
    
    Write-Info "Probando siguiente metodo..."
    Start-Sleep -Seconds 2
}

if (!$Downloaded) {
    Write-Error "No se pudo descargar Ruby portable con ninguno de los metodos disponibles"
    exit 1
}

# Extraer archivo
Write-Info "Extrayendo Ruby portable..."

try {
    # Intentar con 7zip
    if (Get-Command "7z" -ErrorAction SilentlyContinue) {
        Write-Info "Usando 7z para extraer..."
        & 7z x $TempFile "-o$TargetDir" -y | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "7z fallo con codigo $LASTEXITCODE"
        }
    }
    elseif (Get-Command "C:\Program Files\7-Zip\7z.exe" -ErrorAction SilentlyContinue) {
        Write-Info "Usando 7z (ruta completa) para extraer..."
        & "C:\Program Files\7-Zip\7z.exe" x $TempFile "-o$TargetDir" -y | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "7z fallo con codigo $LASTEXITCODE"
        }
    }
    else {
        throw "7-Zip no encontrado"
    }
    
    # Verificar extraccion
    if (Test-Path $RubyExePath) {
        Write-Info "Ruby portable extraido correctamente"
        Write-Info "Ejecutable: $RubyExePath"
        
        # Mostrar version
        $version = & $RubyExePath --version 2>$null
        if ($version) {
            Write-Info "Version: $version"
        }
    } else {
        throw "Ruby executable no encontrado despues de la extraccion"
    }
}
catch {
    Write-Error "Error extrayendo Ruby portable: $_"
    exit 1
}
finally {
    # Limpiar archivo temporal
    if (Test-Path $TempFile) {
        Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Info "[SUCCESS] Ruby portable configurado exitosamente"
