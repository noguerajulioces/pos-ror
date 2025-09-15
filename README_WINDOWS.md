# 🖥️ POS-RoR Desktop para Windows

## 📋 Descripción

**POS-RoR Desktop** es una versión empaquetada de tu sistema de Punto de Venta desarrollado en Ruby on Rails, diseñada para ejecutarse como una aplicación nativa de Windows. Utiliza **Tauri** como framework de aplicación de escritorio, **Ruby portable** para ejecutar Rails sin dependencias del sistema, y **SQLite** como base de datos integrada.

## ✨ Características

- ✅ **Sistema POS completo** con todas las funcionalidades de la versión web
- ✅ **Ruby portable incluido** - no requiere instalación de Ruby en el sistema
- ✅ **Base de datos SQLite** integrada y portable
- ✅ **Instalador MSI** para Windows con distribución sencilla
- ✅ **Interfaz web nativa** ejecutada en ventana de escritorio
- ✅ **Funcionamiento offline** - no requiere conexión a internet
- ✅ **Datos del usuario** almacenados en `%APPDATA%\POS-RoR-Desktop`
- ✅ **Build automatizado** con GitHub Actions

## 🏗️ Arquitectura

```
POS-RoR Desktop/
├── Tauri (Rust)           # Aplicación de escritorio nativa
│   ├── Ventana WebView    # Muestra la interfaz web de Rails
│   ├── Gestión procesos   # Inicia/detiene Rails automáticamente
│   └── Health checks      # Verifica que Rails esté funcionando
│
├── Rails (Ruby portable) # Backend de la aplicación
│   ├── Ruby 3.2.4         # Incluido en el paquete MSI
│   ├── Puma servidor      # Puerto 4317 (localhost)
│   ├── SQLite database    # Base de datos en %APPDATA%
│   └── Assets precompilados
│
└── MSI Installer          # Empaquetado para distribución
    ├── WiX Toolset        # Generador de instalador Windows
    ├── Accesos directos   # Escritorio y menú inicio
    └── Registro Windows   # Integración con el sistema
```

## 🔧 Requisitos del Sistema

### Para Usuarios Finales
- **Windows 10** o superior (x64)
- **2 GB RAM** mínimo (4 GB recomendado)
- **500 MB** espacio libre en disco
- **.NET Framework 4.7.2** o superior

### Para Desarrollo/Build
- **Windows 10/11** (x64)
- **Node.js 18+** con npm
- **Rust** (última versión estable)
- **7-Zip** (para extraer Ruby portable)
- **WiX Toolset** (para generar MSI)
- **Git** para clonar el repositorio

## 🚀 Instalación para Usuarios

### Opción 1: Descargar Release
1. Ve a la página de [Releases](https://github.com/your-username/pos-ror/releases)
2. Descarga el archivo `pos-ror-desktop_*_x64_en-US.msi`
3. Ejecuta el instalador **como administrador**
4. Sigue las instrucciones del instalador
5. La aplicación se instalará en `C:\Program Files\POS-RoR Desktop`
6. Se creará un acceso directo en el escritorio

### Opción 2: Build desde Código Fuente
```bash
# Clonar repositorio
git clone https://github.com/your-username/pos-ror.git
cd pos-ror

# Instalar dependencias Node
npm install

# Preparar recursos Windows (Ruby portable, gems, etc.)
npm run prepare:windows

# Construir MSI
npm run tauri:build

# El MSI estará en: src-tauri/target/release/bundle/msi/
```

## 🛠️ Desarrollo Local

### Setup Inicial
```bash
# 1. Clonar repositorio
git clone https://github.com/your-username/pos-ror.git
cd pos-ror

# 2. Instalar Node dependencies
npm install

# 3. Instalar Tauri CLI
npm install -g @tauri-apps/cli

# 4. Preparar recursos Windows
npm run prepare:windows:verbose
```

### Desarrollo con Hot Reload
```bash
# Opción 1: Desarrollo con Tauri (recomendado)
npm run tauri:dev

# Opción 2: Solo Rails (para desarrollo backend)
npm run dev:rails
# Luego abrir http://localhost:4317 en navegador
```

### Testing
```bash
# Test Rails
npm run test:rails

# Test manual de la aplicación desktop
npm run tauri:dev
```

### Build Local
```bash
# Build completo (preparar recursos + construir MSI)
npm run build:full

# Solo build Tauri (recursos ya preparados)
npm run tauri:build

# Build debug (más rápido, con símbolos de debug)
npm run tauri:build:debug
```

## 🔄 CI/CD con GitHub Actions

El proyecto incluye un workflow completo de GitHub Actions que:

### Triggers
- ✅ Push a `main` o `feature/desktop`
- ✅ Pull requests a `main`
- ✅ Tags `v*` (para releases)
- ✅ Manual dispatch

### Proceso de Build
1. **Setup** - Node.js, Rust, WiX Toolset, 7-Zip
2. **Cache** - Cargo registry, Ruby downloads, Node modules
3. **Preparación** - Descarga Ruby portable, instala gems
4. **Tests** - Ejecuta tests de Rails (opcional)
5. **Build** - Construye MSI con Tauri
6. **Validación** - Verifica que el MSI es válido
7. **Upload** - Sube MSI como artifact
8. **Release** - Publica en GitHub Releases (solo tags)

### Configuración del Workflow
```yaml
# .github/workflows/windows-msi.yml
name: 🚀 Build Windows MSI
on:
  push:
    branches: ["main", "feature/desktop"]
    tags: ["v*"]
  workflow_dispatch:
    inputs:
      skip_tests:
        description: 'Omitir tests'
        default: false
        type: boolean
```

## 📁 Estructura de Archivos

```
pos-ror/
├── 📁 rails/                          # Aplicación Rails
│   ├── 📁 bin/
│   │   └── 📄 start-rails.bat          # Script de inicio Windows
│   ├── 📁 config/
│   │   ├── 📄 database_desktop.yml     # Config SQLite
│   │   ├── 📄 puma_desktop.rb          # Config Puma para desktop
│   │   └── 📁 environments/
│   │       └── 📄 desktop.rb           # Entorno desktop
│   ├── 📄 Gemfile.desktop              # Gems específicas desktop
│   ├── 📁 ruby/                        # Ruby portable (generado)
│   ├── 📁 vendor/bundle/               # Gems empaquetadas (generado)
│   └── 📁 sqlite/                      # SQLite DLL (generado)
│
├── 📁 src-tauri/                       # Aplicación Tauri
│   ├── 📄 tauri.conf.json              # Configuración Tauri
│   ├── 📄 Cargo.toml                   # Dependencias Rust
│   ├── 📄 build.rs                     # Build script
│   └── 📁 src/
│       └── 📄 main.rs                  # Aplicación principal Rust
│
├── 📁 scripts/
│   └── 📄 prepare_windows_resources.ps1 # Preparación recursos Windows
│
├── 📁 .github/workflows/
│   └── 📄 windows-msi.yml              # CI/CD GitHub Actions
│
├── 📄 package.json                     # Config Node.js y scripts
└── 📄 README_WINDOWS.md               # Esta documentación
```

## 🗂️ Ubicaciones de Datos

### Durante el Desarrollo
- **Código fuente**: `./rails/`
- **Ruby portable**: `./rails/ruby/`
- **Gems**: `./rails/vendor/bundle/`
- **Base de datos**: `./rails/db/development.sqlite3`

### En Producción (Usuario Final)
- **Aplicación**: `C:\Program Files\POS-RoR Desktop\`
- **Datos usuario**: `%APPDATA%\POS-RoR-Desktop\`
- **Base de datos**: `%APPDATA%\POS-RoR-Desktop\db\production.sqlite3`
- **Logs**: `%APPDATA%\POS-RoR-Desktop\logs\`
- **Storage**: `%APPDATA%\POS-RoR-Desktop\storage\`

## 🔧 Configuración Avanzada

### Variables de Entorno (Desktop)
```bash
RAILS_ENV=desktop
DATABASE_URL=sqlite3:///%APPDATA%/POS-RoR-Desktop/db/production.sqlite3
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=false
RAILS_STORAGE_PATH=%APPDATA%/POS-RoR-Desktop/storage
```

### Personalizar Ruby Version
Editar `scripts/prepare_windows_resources.ps1`:
```powershell
param(
    [string]$RubyVersion = "3.2.4-1"  # Cambiar aquí
)
```

### Personalizar Puerto
Editar `rails/config/puma_desktop.rb`:
```ruby
port ENV.fetch("PORT") { 4317 }  # Cambiar aquí
```

Y actualizar `src-tauri/tauri.conf.json`:
```json
{
  "build": {
    "devUrl": "http://localhost:4317"  // Cambiar aquí
  },
  "app": {
    "windows": [{
      "url": "http://localhost:4317"  // Y aquí
    }]
  }
}
```

## 🐛 Solución de Problemas

### Build Issues

**Error: "Ruby portable no encontrado"**
```bash
# Limpiar cache y volver a preparar
npm run clean
npm run prepare:windows:verbose
```

**Error: "WiX Toolset no encontrado"**
```bash
# Instalar WiX Toolset
choco install wixtoolset -y
# O descargar desde: https://wixtoolset.org/
```

**Error: "7-Zip no encontrado"**
```bash
# Instalar 7-Zip
choco install 7zip -y
```

### Runtime Issues

**La aplicación no inicia**
1. Verificar que el MSI se instaló correctamente
2. Ejecutar como administrador la primera vez
3. Verificar logs en `%APPDATA%\POS-RoR-Desktop\logs\`

**Rails no responde**
1. Verificar que no hay otro proceso en puerto 4317
2. Verificar permisos de escritura en `%APPDATA%`
3. Reinstalar la aplicación

**Base de datos corrupta**
```bash
# Resetear base de datos (perderá datos)
# Ir a %APPDATA%\POS-RoR-Desktop\
# Eliminar carpeta db/
# Reiniciar aplicación
```

### Antivirus False Positives
Algunos antivirus pueden detectar el MSI como amenaza. Esto es un falso positivo común en aplicaciones empaquetadas. Para solucionarlo:

1. **Whitelist** la carpeta de instalación
2. **Code signing** del MSI (requiere certificado)
3. **VirusTotal** scan para verificar que es seguro

## 📊 Métricas y Monitoreo

### Tamaños Típicos
- **Ruby portable**: ~45 MB
- **Vendor bundle**: ~80 MB  
- **Aplicación Rails**: ~20 MB
- **MSI final**: ~150-200 MB

### Performance
- **Tiempo de inicio**: 10-30 segundos (primera vez)
- **Tiempo de inicio**: 3-5 segundos (subsecuentes)
- **RAM usage**: 150-300 MB
- **CPU usage**: Bajo (<5% en idle)

## 🔐 Seguridad

### Consideraciones
- ✅ Aplicación corre solo en `localhost:4317`
- ✅ No hay conexiones externas requeridas
- ✅ Base de datos local (SQLite)
- ⚠️ Sin encriptación de base de datos por defecto
- ⚠️ Sin autenticación adicional por defecto

### Hardening (Opcional)
```ruby
# config/environments/desktop.rb
config.force_ssl = false  # Cambiar a true si se configura HTTPS
config.web_console.allowed_ips = ['127.0.0.1']  # Solo localhost
```

## 🤝 Contribución

### Para contribuir al proyecto:
1. Fork el repositorio
2. Crear branch: `git checkout -b feature/nueva-funcionalidad`
3. Commit cambios: `git commit -m 'Agregar nueva funcionalidad'`
4. Push branch: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

### Testing de cambios:
```bash
# Test local completo
npm run prepare:windows
npm run tauri:dev

# Test build
npm run build:full

# Verificar MSI generado
src-tauri/target/release/bundle/msi/
```

## 📝 Changelog

### v1.0.0
- ✅ Implementación inicial de empaquetado desktop
- ✅ Ruby portable integrado
- ✅ SQLite como base de datos
- ✅ GitHub Actions para build automatizado
- ✅ Instalador MSI funcional

## 📞 Soporte

### Reportar Issues
- **GitHub Issues**: [Crear issue](https://github.com/your-username/pos-ror/issues)
- **Incluir**: Logs, versión de Windows, pasos para reproducir

### Logs Útiles
```bash
# Logs de la aplicación
%APPDATA%\POS-RoR-Desktop\logs\application.log

# Logs de Rails
%APPDATA%\POS-RoR-Desktop\logs\puma.log

# Logs de Tauri (durante desarrollo)
# Mostrados en consola durante tauri dev
```

## 📜 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).

---

**¡Construido con ❤️ usando Ruby on Rails + Tauri!**

*Para más información sobre el proyecto principal, ver [README.md](README.md)*
