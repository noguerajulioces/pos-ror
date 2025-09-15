@echo off
REM ============================================================================
REM POS-RoR Configuration - Archivo de configuración
REM ============================================================================
REM Este archivo contiene la configuración principal del sistema
REM Edita estos valores según tu instalación específica

REM Directorio del proyecto en WSL (ajustar según tu instalación)
set "PROJECT_DIR=/mnt/c/pos-ror-feature-foot"

REM Comando para iniciar el servidor (normalmente bin/dev)
set "RUN_CMD=bin/dev"

REM Puerto del servidor (para verificación de salud)
set "SERVER_PORT=3000"

REM Directorio de logs en Windows
set "LOG_DIR=%USERPROFILE%\POS-RoR-Logs"

REM Configuración de monitoreo
set "MONITOR_INTERVAL=30"
set "MAX_LOG_SIZE=10485760"

REM Configuración de reintentos
set "MAX_RETRIES=3"
set "RETRY_DELAY=5"

REM Distribución de WSL (opcional, deja vacío para usar la predeterminada)
set "WSL_DISTRO="

REM ============================================================================
REM NO EDITAR DEBAJO DE ESTA LÍNEA
REM ============================================================================
