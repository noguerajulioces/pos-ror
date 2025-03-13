#!/usr/bin/env node

const escpos = require('escpos');
escpos.USB = require('escpos-usb'); // Asigna el módulo USB

// Configura el dispositivo USB
const device = new escpos.USB();
const printer = new escpos.Printer(device);

const args = process.argv.slice(2);
const mensaje = args[0] || 'Mensaje por defecto';

device.open(function(error) {
  if (error) {
    console.error('Error al abrir el dispositivo:', error);
    process.exit(1);
  }
  printer
    .text(mensaje)
    .cut()
    .close();
});
