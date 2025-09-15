@echo off
REM ============================================================================
REM Desinstalador de Auto-Inicio para POS-RoR
REM ============================================================================

echo [POS-RoR] Removiendo auto-inicio...

set "TASK_NAME=POS-RoR-AutoStart"

REM Eliminar tarea programada
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

REM Eliminar entrada del registro
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "POS-RoR-Server" /f >nul 2>&1

echo [POS-RoR] Auto-inicio removido
pause
