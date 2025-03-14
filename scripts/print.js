#!/usr/bin/env node

const escpos = require('escpos');
escpos.USB = require('escpos-usb'); // Asegúrate de tener instalados escpos-usb y usb
const fs = require('fs');

// La ruta del archivo HTML se pasa como argumento
const filePath = process.argv[2];
if (!filePath) {
  console.error("No se especificó el archivo HTML a imprimir");
  process.exit(1);
}

// Lee el contenido del archivo HTML
const contentRaw = fs.readFileSync(filePath, 'utf8');

// Elimina los comentarios no deseados
const content = contentRaw
  .replace(/<!--\s*BEGIN\s*-->/g, '')
  .replace(/<!--\s*END\s*-->/g, '');
  
// Configura el dispositivo USB y la impresora
const device = new escpos.USB();
const printer = new escpos.Printer(device);

device.open(function(error) {
  if (error) {
    console.error('Error al abrir el dispositivo:', error);
    process.exit(1);
  }
  // Imprime el contenido
  printer
    .encode('UTF-8')
    .text(content)
    .cut()
    .close();
});
