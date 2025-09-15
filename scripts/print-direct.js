#!/usr/bin/env node

const fs = require('fs');

// Script de impresión térmica directo - sin dependencias escpos
const filePath = process.argv[2];

console.log("🖨️ POS-RoR Direct Thermal Printer");

if (!filePath) {
  console.log("📄 Imprimiendo texto de prueba...");
  printDirect("=== PRUEBA DE IMPRESION ===\nPOS-RoR Sistema\nFecha: " + new Date().toLocaleString() + "\n" + "=".repeat(30));
  process.exit(0);
}

// Leer y procesar archivo
let content;
try {
  const rawContent = fs.readFileSync(filePath, 'utf8');
  
  // Procesar HTML básico
  content = rawContent
    .replace(/<!--.*?-->/gs, '')
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/p>/gi, '\n')
    .replace(/<[^>]*>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/\n\s*\n/g, '\n')
    .trim();
    
  console.log(`📄 Archivo procesado: ${filePath}`);
  console.log(`📏 Tamaño: ${content.length} caracteres`);
  
} catch (error) {
  console.error(`❌ Error al leer archivo: ${error.message}`);
  content = "ERROR: No se pudo leer el archivo de impresión";
}

printDirect(content);

function printDirect(text) {
  console.log('🔍 Buscando dispositivos de impresión térmica...');
  
  const thermalDevices = [
    '/dev/usb/lp0', '/dev/usb/lp1', '/dev/usb/lp2',
    '/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyUSB2',
    '/dev/ttyACM0', '/dev/ttyACM1', '/dev/ttyACM2'
  ];
  
  for (const device of thermalDevices) {
    try {
      if (fs.existsSync(device)) {
        console.log(`📄 Encontrado dispositivo: ${device}`);
        console.log(`📄 Enviando ${text.length} caracteres...`);
        
        // Escribir directamente al dispositivo
        fs.writeFileSync(device, text + '\n\n\n\x1D\x56\x00'); // Agregar comando de corte
        
        console.log('✅ Impresión enviada correctamente');
        return;
      }
    } catch (error) {
      console.log(`❌ Error en ${device}: ${error.message}`);
    }
  }
  
  // Si no encuentra dispositivos, guardar en archivo
  const backupFile = '/tmp/thermal_direct_backup.txt';
  fs.writeFileSync(backupFile, text);
  console.log(`📝 No se encontraron dispositivos térmicos`);
  console.log(`📝 Contenido guardado en: ${backupFile}`);
  console.log('💡 Comandos útiles:');
  console.log('💡   lsusb                    # Ver dispositivos USB');
  console.log('💡   ls -la /dev/usb/lp*     # Ver impresoras');
  console.log('💡   sudo chmod 666 /dev/usb/lp0  # Dar permisos');
}
