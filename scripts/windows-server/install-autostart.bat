@echo off
REM ============================================================================
REM Instalador de Auto-Inicio para POS-RoR
REM ============================================================================

echo [POS-RoR] Configurando auto-inicio...

set "SCRIPT_DIR=%~dp0"
set "VBS_FILE=%SCRIPT_DIR%pos-invisible-launcher-advanced.vbs"
set "TASK_NAME=POS-RoR-AutoStart"

REM Verificar que los archivos existen
if not exist "%VBS_FILE%" (
    echo [ERROR] Archivo no encontrado: %VBS_FILE%
    pause
    exit /b 1
)

REM Crear tarea programada
echo [POS-RoR] Creando tarea programada...
schtasks /create /tn "%TASK_NAME%" /tr "\"%VBS_FILE%\"" /sc onstart /ru "%USERNAME%" /f >nul 2>&1

if errorlevel 1 (
    echo [ERROR] No se pudo crear la tarea programada
    echo [INFO] Intentando método alternativo (registro)...
    
    REM Método alternativo: Registro de Windows
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "POS-RoR-Server" /t REG_SZ /d "\"%VBS_FILE%\"" /f >nul 2>&1
    
    if errorlevel 1 (
        echo [ERROR] No se pudo configurar el auto-inicio
        pause
        exit /b 1
    ) else (
        echo [POS-RoR] Auto-inicio configurado via registro
    )
) else (
    echo [POS-RoR] Auto-inicio configurado via tarea programada
)

echo [POS-RoR] Configuración completada
echo [INFO] El servidor se iniciará automáticamente con Windows
pause
