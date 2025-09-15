@echo off
echo Iniciando POS-RoR...

REM Verificar Node.js
echo Verificando Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js no esta instalado
    echo [INFO] Descargar desde: https://nodejs.org/
    echo [INFO] Instalar version LTS y reiniciar este script
    pause
    exit /b 1
) else (
    echo [OK] Node.js disponible
)

REM Guardar cambios locales, actualizar y restaurar
echo Guardando cambios locales...
wsl.exe --exec bash -i -c "cd /mnt/c/pos-ror-feature-foot && git stash"

echo Verificando actualizaciones...
wsl.exe --exec bash -i -c "cd /mnt/c/pos-ror-feature-foot && git pull"

echo Restaurando cambios locales...
wsl.exe --exec bash -i -c "cd /mnt/c/pos-ror-feature-foot && git stash pop"

REM Matar cualquier Rails que esté corriendo en puerto 3000
echo Deteniendo servidor anterior...
wsl.exe --exec bash -i -c "pkill -f 'rails.*3000\|puma.*3000' 2>/dev/null || true"

REM Esperar 2 segundos
timeout /t 2 /nobreak >nul

REM Ir al directorio del proyecto y levantar Rails en daemon
echo Iniciando servidor...
wsl.exe --exec bash -i -c "cd /mnt/c/pos-ror-feature-foot && rails s -d"

REM Esperar 5 segundos para que se levante
timeout /t 5 /nobreak >nul

REM Abrir el browser
echo Abriendo browser...
start "" "http://localhost:3000"

echo Listo! POS-RoR iniciado en localhost:3000
exit
