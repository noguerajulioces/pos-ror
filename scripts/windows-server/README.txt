============================================================================
POS-RoR Server Manager - Guía de Uso
============================================================================

ARCHIVOS INCLUIDOS:
- pos-server-manager.bat         : Script principal del servidor
- pos-invisible-launcher-advanced.vbs : Launcher invisible con reintentos
- pos-health-monitor.bat         : Monitor de salud continuo
- pos-log-viewer.bat            : Visor de logs con filtros
- install-autostart.bat         : Instalar auto-inicio
- uninstall-autostart.bat       : Desinstalar auto-inicio

INSTALACIÓN:
1. Copiar todos los archivos a una carpeta (ej: C:\POS-RoR-Scripts)
2. Ejecutar install-autostart.bat como administrador
3. Reiniciar Windows para probar el auto-inicio

USO MANUAL:
- Iniciar servidor: pos-server-manager.bat start
- Detener servidor: pos-server-manager.bat stop
- Reiniciar servidor: pos-server-manager.bat restart
- Ver estado: pos-server-manager.bat status

MONITOREO:
- Ejecutar pos-health-monitor.bat para monitoreo continuo
- Los logs se guardan en %USERPROFILE%\POS-RoR-Logs\
- Usar pos-log-viewer.bat para ver logs de forma organizada

CARACTERÍSTICAS:
✓ Ejecución completamente silenciosa
✓ Auto-inicio con Windows
✓ Reintentos automáticos
✓ Monitoreo de salud continuo
✓ Rotación automática de logs
✓ Detección y reinicio automático si falla
✓ Interfaz simple para visualizar logs

TROUBLESHOOTING:
- Si el servidor no inicia, revisar logs en POS-RoR-Logs
- Verificar que WSL esté funcionando: wsl.exe --list
- Asegurar que el directorio del proyecto existe
- Para desinstalar: ejecutar uninstall-autostart.bat

CONFIGURACIÓN:
- El directorio del proyecto se configura en pos-server-manager.bat
- Por defecto usa: /mnt/c/pos-ror-feature-foot
- Cambiar la variable PROJECT_DIR si tu proyecto está en otro lugar

LOGS:
- Los logs se almacenan en: %USERPROFILE%\POS-RoR-Logs\
- pos-ror.log: Logs del servidor principal
- health-monitor.log: Logs del monitor de salud
- performance.log: Logs de rendimiento
- invisible-launcher.log: Logs del launcher invisible

CONTACTO:
- Para reportar problemas o sugerencias, revisar los logs primero
- Los logs contienen información detallada sobre cualquier error
