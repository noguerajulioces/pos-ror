@echo off
REM ============================================================================
REM POS-RoR System Test - Prueba completa del sistema
REM ============================================================================

setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
set "LOG_FILE=%TEMP%\pos-ror-test.log"

echo ============================================================================
echo POS-RoR System Test - Verificación completa del sistema
echo ============================================================================
echo.

REM Inicializar log de pruebas
echo === POS-RoR System Test - %DATE% %TIME% === > "%LOG_FILE%"

REM Test 1: Verificar archivos necesarios
echo [TEST 1/8] Verificando archivos del sistema...
call :TestFiles
echo.

REM Test 2: Verificar WSL
echo [TEST 2/8] Verificando WSL...
call :TestWSL
echo.

REM Test 3: Verificar directorio del proyecto
echo [TEST 3/8] Verificando directorio del proyecto...
call :TestProjectDirectory
echo.

REM Test 4: Probar script principal
echo [TEST 4/8] Probando script principal...
call :TestMainScript
echo.

REM Test 5: Probar funciones de logging
echo [TEST 5/8] Probando sistema de logging...
call :TestLogging
echo.

REM Test 6: Probar launcher invisible
echo [TEST 6/8] Probando launcher invisible...
call :TestInvisibleLauncher
echo.

REM Test 7: Verificar configuración de auto-inicio
echo [TEST 7/8] Verificando configuración de auto-inicio...
call :TestAutostart
echo.

REM Test 8: Resumen final
echo [TEST 8/8] Generando resumen...
call :TestSummary
echo.

echo ============================================================================
echo Pruebas completadas. Ver detalles en: %LOG_FILE%
echo ============================================================================
pause
goto :EOF

REM ============================================================================
REM FUNCIONES DE PRUEBA
REM ============================================================================

:TestFiles
set "FILES_OK=true"
set "REQUIRED_FILES=pos-server-manager.bat pos-invisible-launcher-advanced.vbs install-autostart.bat"

for %%f in (%REQUIRED_FILES%) do (
    if exist "%SCRIPT_DIR%%%f" (
        echo [OK] %%f encontrado
        echo [OK] %%f encontrado >> "%LOG_FILE%"
    ) else (
        echo [ERROR] %%f NO encontrado
        echo [ERROR] %%f NO encontrado >> "%LOG_FILE%"
        set "FILES_OK=false"
    )
)

if "%FILES_OK%"=="true" (
    echo [RESULTADO] Todos los archivos necesarios están presentes
) else (
    echo [RESULTADO] Faltan archivos necesarios
)
goto :EOF

:TestWSL
wsl.exe --list --quiet >nul 2>&1
if errorlevel 1 (
    echo [ERROR] WSL no disponible
    echo [ERROR] WSL no disponible >> "%LOG_FILE%"
) else (
    echo [OK] WSL disponible
    echo [OK] WSL disponible >> "%LOG_FILE%"
    
    REM Mostrar distribuciones disponibles
    echo [INFO] Distribuciones WSL disponibles:
    wsl.exe --list --verbose
)
goto :EOF

:TestProjectDirectory
set "PROJECT_DIR=/mnt/c/pos-ror-feature-foot"
wsl.exe -c "test -d %PROJECT_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Directorio del proyecto no encontrado: %PROJECT_DIR%
    echo [WARNING] Directorio del proyecto no encontrado >> "%LOG_FILE%"
    echo [INFO] Esto es normal si aún no has configurado el proyecto
) else (
    echo [OK] Directorio del proyecto encontrado
    echo [OK] Directorio del proyecto encontrado >> "%LOG_FILE%"
    
    REM Verificar archivos importantes en el proyecto
    wsl.exe -c "test -f %PROJECT_DIR%/bin/dev" >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] bin/dev no encontrado en el proyecto
    ) else (
        echo [OK] bin/dev encontrado en el proyecto
    )
)
goto :EOF

:TestMainScript
echo [INFO] Probando script principal con comando 'status'...
call "%SCRIPT_DIR%pos-server-manager.bat" status >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Script principal reportó error (normal si el servidor no está ejecutándose)
    echo [WARNING] Script principal reportó error >> "%LOG_FILE%"
) else (
    echo [OK] Script principal ejecutado correctamente
    echo [OK] Script principal ejecutado correctamente >> "%LOG_FILE%"
)
goto :EOF

:TestLogging
set "TEST_LOG_DIR=%USERPROFILE%\POS-RoR-Logs"
if not exist "%TEST_LOG_DIR%" mkdir "%TEST_LOG_DIR%"

echo Test de logging > "%TEST_LOG_DIR%\test.log"
if exist "%TEST_LOG_DIR%\test.log" (
    echo [OK] Sistema de logging funciona correctamente
    echo [OK] Sistema de logging funciona correctamente >> "%LOG_FILE%"
    del "%TEST_LOG_DIR%\test.log"
) else (
    echo [ERROR] No se pudo crear archivo de log
    echo [ERROR] No se pudo crear archivo de log >> "%LOG_FILE%"
)
goto :EOF

:TestInvisibleLauncher
if exist "%SCRIPT_DIR%pos-invisible-launcher-advanced.vbs" (
    echo [OK] Launcher invisible encontrado
    echo [OK] Launcher invisible encontrado >> "%LOG_FILE%"
    echo [INFO] Para probar completamente, ejecutar manualmente el .vbs
) else (
    echo [ERROR] Launcher invisible no encontrado
    echo [ERROR] Launcher invisible no encontrado >> "%LOG_FILE%"
)
goto :EOF

:TestAutostart
REM Verificar si ya está configurado el auto-inicio
schtasks /query /tn "POS-RoR-AutoStart" >nul 2>&1
if errorlevel 1 (
    REM Verificar registro
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "POS-RoR-Server" >nul 2>&1
    if errorlevel 1 (
        echo [INFO] Auto-inicio no configurado (ejecutar install-autostart.bat para configurar)
        echo [INFO] Auto-inicio no configurado >> "%LOG_FILE%"
    ) else (
        echo [OK] Auto-inicio configurado via registro
        echo [OK] Auto-inicio configurado via registro >> "%LOG_FILE%"
    )
) else (
    echo [OK] Auto-inicio configurado via tarea programada
    echo [OK] Auto-inicio configurado via tarea programada >> "%LOG_FILE%"
)
goto :EOF

:TestSummary
echo === RESUMEN DE PRUEBAS === >> "%LOG_FILE%"
echo Test completado el %DATE% %TIME% >> "%LOG_FILE%"
echo.
echo [INFO] Resumen guardado en: %LOG_FILE%
echo [INFO] Para ver logs detallados usar: pos-log-viewer.bat
echo [INFO] Para configuración inicial usar: quick-setup.bat
goto :EOF
