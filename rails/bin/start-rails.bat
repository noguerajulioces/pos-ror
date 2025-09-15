@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM POS-RoR Desktop - Rails Startup Script for Windows
REM ============================================================================
REM Este script inicia Rails con Ruby portable para la aplicación de escritorio
REM Configura SQLite, directorios de datos y ejecuta Puma en puerto 4317

echo [POS-RoR] Iniciando aplicación de escritorio...

REM 1) Ubicación base (carpeta rails dentro del paquete)
set APPDIR=%~dp0..
cd /d "%APPDIR%"
echo [POS-RoR] Directorio de aplicación: %APPDIR%

REM 2) Ruby portable en PATH (incluido en el paquete MSI)
set PATH=%APPDIR%\ruby\bin;%APPDIR%\ruby\msys64\mingw64\bin;%PATH%
echo [POS-RoR] Ruby portable configurado

REM 3) Directorios de datos del usuario (en %APPDATA%)
set DATA_DIR=%APPDATA%\POS-RoR-Desktop
if not exist "%DATA_DIR%\db" (
    echo [POS-RoR] Creando directorio de base de datos...
    mkdir "%DATA_DIR%\db"
)
if not exist "%DATA_DIR%\logs" (
    echo [POS-RoR] Creando directorio de logs...
    mkdir "%DATA_DIR%\logs"
)
if not exist "%DATA_DIR%\storage" (
    echo [POS-RoR] Creando directorio de storage...
    mkdir "%DATA_DIR%\storage"
)

REM 4) Variables de entorno Rails para modo desktop
set RAILS_ENV=desktop
set RAILS_LOG_TO_STDOUT=false
set RAILS_LOG_LEVEL=info
set DATABASE_URL=sqlite3:///%DATA_DIR:\=/%/db/production.sqlite3
set RAILS_SERVE_STATIC_FILES=true
set RAILS_STORAGE_PATH=%DATA_DIR%\storage

REM 5) Configuración de Bundler (gems preinstaladas en vendor/bundle)
echo [POS-RoR] Configurando Bundler...
bundle config set --local deployment true
bundle config set --local path vendor/bundle
bundle config set --local without development:test

REM 6) Verificar si es la primera ejecución (migrar base de datos)
if not exist "%DATA_DIR%\db\production.sqlite3" (
    echo [POS-RoR] Primera ejecución - configurando base de datos...
    bundle exec rails db:create db:migrate RAILS_ENV=desktop
    echo [POS-RoR] Ejecutando seeds iniciales...
    bundle exec rails db:seed RAILS_ENV=desktop
) else (
    echo [POS-RoR] Verificando migraciones pendientes...
    bundle exec rails db:migrate RAILS_ENV=desktop
)

REM 7) Precompilar assets si no existen
if not exist "public\assets" (
    echo [POS-RoR] Precompilando assets...
    bundle exec rails assets:precompile RAILS_ENV=desktop
)

REM 8) Iniciar Puma en puerto 4317
echo [POS-RoR] Iniciando servidor web en puerto 4317...
echo [POS-RoR] Base de datos: %DATA_DIR%\db\production.sqlite3
echo [POS-RoR] Logs: %DATA_DIR%\logs
echo [POS-RoR] ============================================
bundle exec puma -e desktop -p 4317 -t 2:8 --preload

REM Si llegamos aquí, Puma se cerró
echo [POS-RoR] Servidor web detenido
pause
