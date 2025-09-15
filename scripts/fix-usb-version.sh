#!/bin/bash

# Script para instalar versión compatible de USB
echo "🔧 Instalando versión compatible de USB para escpos..."

# Desinstalar versión problemática
npm uninstall usb

# Instalar versión específica que funciona con escpos-usb
npm install usb@1.9.2

echo "✅ USB versión 1.9.2 instalada"
echo "🧪 Probando: node scripts/print.js"
