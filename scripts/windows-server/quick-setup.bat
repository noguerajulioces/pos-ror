@echo off
REM ============================================================================
REM POS-RoR Quick Setup - Configuración rápida del sistema
REM ============================================================================

echo ============================================================================
echo POS-RoR Server Manager - Configuración Rápida
echo ============================================================================
echo.

REM Verificar si se ejecuta como administrador
net session >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Se recomienda ejecutar como administrador para mejor funcionamiento
    echo [INFO] Continuando con permisos de usuario normal...
    echo.
)

REM 1. Verificar WSL
echo [1/5] Verificando WSL...
wsl.exe --list --quiet >nul 2>&1
if errorlevel 1 (
    echo [ERROR] WSL no está disponible. Por favor instalar WSL primero.
    echo [INFO] Visitar: https://docs.microsoft.com/en-us/windows/wsl/install
    pause
    exit /b 1
) else (
    echo [OK] WSL disponible
)

REM 2. Verificar directorio del proyecto
echo [2/5] Verificando directorio del proyecto...
set "PROJECT_DIR=/mnt/c/pos-ror-feature-foot"
wsl.exe -c "test -d %PROJECT_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Directorio del proyecto no encontrado: %PROJECT_DIR%
    echo [INFO] Asegúrate de que el proyecto esté en la ubicación correcta
    echo [INFO] O edita PROJECT_DIR en pos-server-manager.bat
) else (
    echo [OK] Directorio del proyecto encontrado
)

REM 3. Crear directorio de logs
echo [3/5] Creando directorio de logs...
set "LOG_DIR=%USERPROFILE%\POS-RoR-Logs"
if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
    echo [OK] Directorio de logs creado: %LOG_DIR%
) else (
    echo [OK] Directorio de logs ya existe
)

REM 4. Probar el servidor manualmente
echo [4/5] Probando el servidor...
echo [INFO] Ejecutando una prueba rápida del servidor...
call "%~dp0pos-server-manager.bat" status

REM 5. Configurar auto-inicio
echo [5/5] Configurar auto-inicio...
echo.
set /p "AUTOSTART=¿Deseas configurar el auto-inicio con Windows? (S/N): "
if /i "%AUTOSTART%"=="S" (
    call "%~dp0install-autostart.bat"
) else (
    echo [INFO] Auto-inicio omitido. Puedes configurarlo más tarde ejecutando install-autostart.bat
)

echo.
echo ============================================================================
echo Configuración completada
echo ============================================================================
echo.
echo PRÓXIMOS PASOS:
echo 1. Probar manualmente: pos-server-manager.bat start
echo 2. Ver logs: pos-log-viewer.bat
echo 3. Monitoreo continuo: pos-health-monitor.bat
echo.
echo ARCHIVOS DISPONIBLES:
echo - pos-server-manager.bat    : Control del servidor
echo - pos-invisible-launcher-advanced.vbs : Launcher invisible
echo - pos-health-monitor.bat    : Monitor de salud
echo - pos-log-viewer.bat       : Visor de logs
echo - install-autostart.bat    : Configurar auto-inicio
echo - uninstall-autostart.bat  : Remover auto-inicio
echo.
pause
