#!/usr/bin/env node

const fs = require('fs');

// Parche para el error usb.on is not a function
let escpos, escposUSB;
try {
  // Parchear el módulo USB antes de cargarlo
  const usb = require('usb');
  if (!usb.on && usb.usb && usb.usb.on) {
    // Redirigir usb.on a usb.usb.on si es necesario
    usb.on = usb.usb.on.bind(usb.usb);
  }
  
  escpos = require('escpos');
  escpos.USB = require('escpos-usb');
  escposUSB = true;
  console.log("✅ Módulos escpos cargados correctamente");
} catch (error) {
  console.log(`ℹ️ Error cargando escpos: ${error.message}`);
  console.log("🔄 Usando método alternativo...");
  escposUSB = false;
}

// La ruta del archivo HTML se pasa como argumento
const filePath = process.argv[2];

if (!filePath) {
  console.error("No se especificó el archivo HTML a imprimir. Se imprimirá 'HOLA' por defecto.");
  printText("HOLA");
  process.exit(0);
}

// Intenta leer el archivo
let contentRaw;
try {
  contentRaw = fs.readFileSync(filePath, 'utf8').trim();
} catch (error) {
  console.error(`Error al leer el archivo: ${error.message}`);
  console.log("Se imprimirá 'HOLA' por defecto.");
  printText("HOLA");
  process.exit(0);
}

// Si el contenido está vacío, imprimir "HOLA"
const content = contentRaw
  .replace(/<!--\s*BEGIN\s*-->/g, '')
  .replace(/<!--\s*END\s*-->/g, '')
  .trim();

if (!content) {
  console.log("El archivo está vacío. Se imprimirá 'HOLA'.");
  printText("HOLA");
} else {
  printText(content);
}

/**
 * Función para imprimir texto en la impresora térmica
 * @param {string} text
 */
function printText(text) {
  if (!escposUSB) {
    console.log("❌ Módulos escpos no disponibles");
    printAlternative(text);
    return;
  }

  try {
    console.log("🖨️ Intentando imprimir con escpos...");
    const device = new escpos.USB();
    const printer = new escpos.Printer(device);

    device.open(function(error) {
      if (error) {
        console.error('❌ Error al abrir dispositivo escpos:', error.message);
        console.log("🔄 Intentando método alternativo...");
        printAlternative(text);
        return;
      }
      
      console.log("✅ Dispositivo abierto, enviando texto...");
      printer
        .encode('UTF-8')
        .text(text)
        .cut()
        .close();
      console.log("✅ Impresión completada via escpos");
    });
  } catch (error) {
    console.error('❌ Error con escpos:', error.message);
    console.log("🔄 Usando método alternativo...");
    printAlternative(text);
  }
}

function printAlternative(text) {
  console.log('🔍 Método alternativo: buscando dispositivos USB...');
  
  const usbDevices = ['/dev/usb/lp0', '/dev/usb/lp1', '/dev/ttyUSB0', '/dev/ttyACM0'];
  
  for (const device of usbDevices) {
    try {
      if (fs.existsSync(device)) {
        console.log(`📄 Encontrado: ${device}`);
        fs.writeFileSync(device, text + '\n\n\n');
        console.log('✅ Impresión enviada via USB directo');
        return;
      }
    } catch (error) {
      console.log(`❌ Error en ${device}: ${error.message}`);
    }
  }
  
  // Guardar en archivo como último recurso
  const backupFile = '/tmp/thermal_backup.txt';
  fs.writeFileSync(backupFile, text);
  console.log(`📝 Guardado en: ${backupFile}`);
  console.log('💡 Verifica tu impresora con: lsusb');
}
