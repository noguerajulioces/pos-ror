@echo off
REM ============================================================================
REM POS-RoR Log Viewer - Visor de logs con filtros
REM ============================================================================

setlocal enabledelayedexpansion
set "LOG_DIR=%USERPROFILE%\POS-RoR-Logs"

:MainMenu
cls
echo ============================================================================
echo POS-RoR Log Viewer
echo ============================================================================
echo.
echo 1. Ver logs del servidor (últimas 50 líneas)
echo 2. Ver logs de salud (últimas 50 líneas)
echo 3. Ver logs de rendimiento (últimas 50 líneas)
echo 4. Ver errores únicamente
echo 5. Limpiar todos los logs
echo 6. Ver estadísticas de logs
echo 7. Salir
echo.
set /p "CHOICE=Selecciona una opción (1-7): "

if "%CHOICE%"=="1" call :ShowServerLogs
if "%CHOICE%"=="2" call :ShowHealthLogs
if "%CHOICE%"=="3" call :ShowPerformanceLogs
if "%CHOICE%"=="4" call :ShowErrors
if "%CHOICE%"=="5" call :ClearLogs
if "%CHOICE%"=="6" call :ShowStats
if "%CHOICE%"=="7" goto :EOF

pause
goto :MainMenu

:ShowServerLogs
cls
echo === LOGS DEL SERVIDOR (Últimas 50 líneas) ===
if exist "%LOG_DIR%\pos-ror.log" (
    powershell "Get-Content '%LOG_DIR%\pos-ror.log' -Tail 50"
) else (
    echo No hay logs del servidor disponibles
)
goto :EOF

:ShowHealthLogs
cls
echo === LOGS DE SALUD (Últimas 50 líneas) ===
if exist "%LOG_DIR%\health-monitor.log" (
    powershell "Get-Content '%LOG_DIR%\health-monitor.log' -Tail 50"
) else (
    echo No hay logs de salud disponibles
)
goto :EOF

:ShowPerformanceLogs
cls
echo === LOGS DE RENDIMIENTO (Últimas 50 líneas) ===
if exist "%LOG_DIR%\performance.log" (
    powershell "Get-Content '%LOG_DIR%\performance.log' -Tail 50"
) else (
    echo No hay logs de rendimiento disponibles
)
goto :EOF

:ShowErrors
cls
echo === ERRORES ÚNICAMENTE ===
for %%f in ("%LOG_DIR%\*.log") do (
    echo.
    echo === Errores en %%~nxf ===
    findstr /i "error\|warning\|fail" "%%f" 2>nul
)
goto :EOF

:ClearLogs
set /p "CONFIRM=¿Estás seguro de que quieres limpiar todos los logs? (S/N): "
if /i "%CONFIRM%"=="S" (
    del "%LOG_DIR%\*.log" 2>nul
    echo Logs limpiados correctamente
) else (
    echo Operación cancelada
)
goto :EOF

:ShowStats
cls
echo === ESTADÍSTICAS DE LOGS ===
echo.
for %%f in ("%LOG_DIR%\*.log") do (
    echo Archivo: %%~nxf
    echo Tamaño: %%~zf bytes
    for /f %%i in ('find /c /v "" ^< "%%f"') do echo Líneas: %%i
    echo Última modificación: %%~tf
    echo.
)
goto :EOF
