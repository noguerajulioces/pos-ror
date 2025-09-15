@echo off
REM ============================================================================
REM POS-RoR Server Manager - Simple y Robusto
REM ============================================================================
REM Uso: pos-server-manager.bat [start|stop|restart|status]

setlocal enabledelayedexpansion
set "ACTION=%1"
set "PROJECT_DIR=/mnt/c/pos-ror-feature-foot"
set "LOG_DIR=%USERPROFILE%\POS-RoR-Logs"

REM Crear directorio de logs si no existe
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Si no se especifica acción, usar 'start'
if "%ACTION%"=="" set "ACTION=start"

REM Ejecutar la acción solicitada
if /i "%ACTION%"=="start" call :StartServer
if /i "%ACTION%"=="stop" call :StopServer
if /i "%ACTION%"=="restart" call :RestartServer
if /i "%ACTION%"=="status" call :CheckStatus
goto :EOF

REM ============================================================================
REM FUNCIONES
REM ============================================================================

:StartServer
echo [POS-RoR] Iniciando servidor...
call :LogMessage "Iniciando servidor"

REM 1. Verificar WSL disponible
call :CheckWSL
if errorlevel 1 goto :Error

REM 2. Matar procesos existentes
call :KillExistingProcesses

REM 3. Verificar directorio del proyecto
call :CheckProjectDirectory
if errorlevel 1 goto :Error

REM 4. Iniciar servidor
call :LaunchServer
goto :EOF

:StopServer
echo [POS-RoR] Deteniendo servidor...
call :LogMessage "Deteniendo servidor"
call :KillExistingProcesses
echo [POS-RoR] Servidor detenido
goto :EOF

:RestartServer
echo [POS-RoR] Reiniciando servidor...
call :StopServer
timeout /t 3 /nobreak >nul
call :StartServer
goto :EOF

:CheckStatus
echo [POS-RoR] Verificando estado del servidor...
wsl.exe -c "pgrep -f 'bin/dev\|rails server\|puma' > /dev/null && echo 'EJECUTANDOSE' || echo 'DETENIDO'"
goto :EOF

:CheckWSL
wsl.exe --list --quiet >nul 2>&1
if errorlevel 1 (
    echo [ERROR] WSL no está disponible o configurado
    call :LogMessage "ERROR: WSL no disponible"
    exit /b 1
)
goto :EOF

:CheckProjectDirectory
wsl.exe -c "test -d %PROJECT_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Directorio del proyecto no encontrado: %PROJECT_DIR%
    call :LogMessage "ERROR: Directorio no encontrado"
    exit /b 1
)
goto :EOF

:KillExistingProcesses
echo [POS-RoR] Deteniendo procesos existentes...
call :LogMessage "Matando procesos existentes"

REM Matar procesos con nombres específicos
wsl.exe -c "pkill -f 'bin/dev' 2>/dev/null || true"
wsl.exe -c "pkill -f 'rails server' 2>/dev/null || true"
wsl.exe -c "pkill -f 'puma' 2>/dev/null || true"
wsl.exe -c "pkill -f 'foreman' 2>/dev/null || true"

REM Esperar que terminen
timeout /t 2 /nobreak >nul
goto :EOF

:LaunchServer
echo [POS-RoR] Lanzando servidor en background...
call :LogMessage "Lanzando servidor"

REM Iniciar servidor y guardar PID
start /min "" wsl.exe --exec bash -i -c "cd %PROJECT_DIR% && nohup bin/dev > /tmp/pos-ror.log 2>&1 & echo \$! > /tmp/pos-ror.pid && echo 'Servidor iniciado con PID:' && cat /tmp/pos-ror.pid"

REM Verificar que se inició
timeout /t 5 /nobreak >nul
wsl.exe -c "test -f /tmp/pos-ror.pid" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No se pudo iniciar el servidor
    call :LogMessage "ERROR: Fallo al iniciar servidor"
    goto :Error
) else (
    echo [POS-RoR] Servidor iniciado correctamente
    call :LogMessage "Servidor iniciado exitosamente"
)
goto :EOF

:LogMessage
set "MSG=%~1"
echo %DATE% %TIME% - %MSG% >> "%LOG_DIR%\pos-ror.log"
goto :EOF

:Error
echo [POS-RoR] Error durante la operación. Ver logs en: %LOG_DIR%
call :LogMessage "ERROR: Operación fallida"
pause
exit /b 1
