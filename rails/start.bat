@echo off
REM POS-RoR Desktop - Script de inicio para Windows

echo [POS-RoR] Iniciando aplicacion portable...

REM Cambiar al directorio del script
cd /d "%~dp0"

REM Intentar usar Ruby portable si existe
if exist "ruby\bin\ruby.exe" (
    echo [POS-RoR] Usando Ruby portable
    set RUBY_EXE=ruby\bin\ruby.exe
) else (
    echo [POS-RoR] Usando Ruby del sistema
    set RUBY_EXE=ruby
)

REM Iniciar aplicacion
echo [POS-RoR] Ejecutando: %RUBY_EXE% start.rb
%RUBY_EXE% start.rb

REM Si falla, pausar para ver error
if errorlevel 1 (
    echo [POS-RoR] Error al iniciar aplicacion
    pause
)
