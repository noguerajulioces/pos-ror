@echo off
REM ============================================================================
REM POS-RoR Health Monitor - Sistema de monitoreo y logging avanzado
REM ============================================================================

setlocal enabledelayedexpansion
set "PROJECT_DIR=/mnt/c/pos-ror-feature-foot"
set "LOG_DIR=%USERPROFILE%\POS-RoR-Logs"
set "HEALTH_LOG=%LOG_DIR%\health-monitor.log"
set "PERFORMANCE_LOG=%LOG_DIR%\performance.log"

REM Crear directorio de logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Ejecutar monitoreo continuo
call :MonitorHealth

goto :EOF

REM ============================================================================
REM FUNCIONES DE MONITOREO
REM ============================================================================

:MonitorHealth
call :LogHealth "=== Iniciando monitoreo de salud ==="

:MonitorLoop
REM Verificar estado del servidor
call :CheckServerStatus
call :CheckServerPerformance
call :CheckSystemResources
call :CheckLogSize

REM Esperar 30 segundos antes del siguiente chequeo
timeout /t 30 /nobreak >nul
goto :MonitorLoop

:CheckServerStatus
set "SERVER_STATUS=UNKNOWN"

REM Verificar si el proceso está ejecutándose
wsl.exe -c "pgrep -f 'bin/dev\|rails server\|puma' > /dev/null" >nul 2>&1
if errorlevel 1 (
    set "SERVER_STATUS=STOPPED"
    call :LogHealth "WARNING: Servidor detenido - Intentando reiniciar"
    call :RestartServer
) else (
    set "SERVER_STATUS=RUNNING"
    
    REM Verificar si responde en el puerto
    call :CheckPortResponse
)

call :LogHealth "INFO: Estado del servidor: !SERVER_STATUS!"
goto :EOF

:CheckPortResponse
REM Verificar si el puerto 3000 responde (ajustar según tu configuración)
wsl.exe -c "timeout 5 bash -c '</dev/tcp/localhost/3000' 2>/dev/null" >nul 2>&1
if errorlevel 1 (
    call :LogHealth "WARNING: Servidor no responde en puerto 3000"
    set "SERVER_STATUS=NOT_RESPONDING"
) else (
    set "SERVER_STATUS=HEALTHY"
)
goto :EOF

:CheckServerPerformance
REM Obtener información de rendimiento
for /f "tokens=*" %%i in ('wsl.exe -c "ps aux | grep -E 'bin/dev|rails|puma' | grep -v grep | awk '{print $3,$4}' | head -1"') do (
    set "PERF_DATA=%%i"
)

if defined PERF_DATA (
    call :LogPerformance "CPU/MEM: !PERF_DATA!"
) else (
    call :LogPerformance "No performance data available"
)
goto :EOF

:CheckSystemResources
REM Verificar recursos del sistema
for /f "tokens=2 delims=:" %%i in ('wmic OS get TotalVisibleMemorySize /value ^| find "="') do set "TOTAL_MEM=%%i"
for /f "tokens=2 delims=:" %%i in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set "FREE_MEM=%%i"

if defined TOTAL_MEM if defined FREE_MEM (
    set /a "MEM_USAGE_PERCENT=100-(!FREE_MEM!*100/!TOTAL_MEM!)"
    call :LogPerformance "Memoria del sistema: !MEM_USAGE_PERCENT!%% utilizada"
    
    REM Alerta si el uso de memoria es alto
    if !MEM_USAGE_PERCENT! GTR 90 (
        call :LogHealth "WARNING: Uso alto de memoria del sistema: !MEM_USAGE_PERCENT!%%"
    )
)
goto :EOF

:CheckLogSize
REM Verificar tamaño de logs y rotarlos si es necesario
for %%f in ("%LOG_DIR%\*.log") do (
    set "FILE_SIZE=%%~zf"
    if defined FILE_SIZE (
        REM Si el archivo es mayor a 10MB (10485760 bytes)
        if !FILE_SIZE! GTR 10485760 (
            call :RotateLog "%%f"
        )
    )
)
goto :EOF

:RotateLog
set "LOG_FILE=%~1"
set "BACKUP_FILE=%LOG_FILE%.backup"

if exist "%BACKUP_FILE%" del "%BACKUP_FILE%"
move "%LOG_FILE%" "%BACKUP_FILE%" >nul 2>&1
call :LogHealth "INFO: Log rotado: %LOG_FILE%"
goto :EOF

:RestartServer
call :LogHealth "INFO: Intentando reiniciar servidor"
call "%~dp0pos-server-manager.bat" restart >nul 2>&1
goto :EOF

:LogHealth
set "MSG=%~1"
echo %DATE% %TIME% - %MSG% >> "%HEALTH_LOG%"
goto :EOF

:LogPerformance
set "MSG=%~1"
echo %DATE% %TIME% - %MSG% >> "%PERFORMANCE_LOG%"
goto :EOF
