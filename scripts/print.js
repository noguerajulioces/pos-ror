#!/usr/bin/env node

const escpos = require('escpos');
escpos.USB = require('escpos-usb'); // Asegúrate de tener instalados escpos-usb y usb
const fs = require('fs');

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
  const device = new escpos.USB();
  const printer = new escpos.Printer(device);

  device.open(function(error) {
    if (error) {
      console.error('Error al abrir el dispositivo:', error);
      process.exit(1);
    }
    printer
      .encode('UTF-8')
      .text(text)
      .cut()
      .close();
  });
}
