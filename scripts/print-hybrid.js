#!/usr/bin/env node

const fs = require('fs');
const { spawn } = require('child_process');

// Script híbrido que funciona en WSL pero usa Windows para imprimir
const filePath = process.argv[2];

console.log("🖨️ POS-RoR Hybrid Printer (WSL + Windows)");

if (!filePath) {
  console.log("No se especificó archivo. Imprimiendo texto de prueba...");
  printContent("=== PRUEBA DE IMPRESION ===\nPOS-RoR Sistema\nFecha: " + new Date().toLocaleString() + "\n" + "=".repeat(30));
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

printContent(content);

function printContent(text) {
  console.log("🔍 Intentando métodos de impresión...");
  
  // Método 1: Dispositivo USB directo en WSL
  tryDirectUSB(text, () => {
    // Método 2: Usar PowerShell de Windows desde WSL
    tryWindowsPowerShell(text, () => {
      // Método 3: Guardar en archivo compartido
      saveToSharedFile(text);
    });
  });
}

function tryDirectUSB(text, fallback) {
  const usbDevices = ['/dev/usb/lp0', '/dev/usb/lp1', '/dev/ttyUSB0', '/dev/ttyACM0'];
  
  for (const device of usbDevices) {
    try {
      if (fs.existsSync(device)) {
        console.log(`📄 Intentando dispositivo USB: ${device}`);
        fs.writeFileSync(device, text + '\n\n\n');
        console.log("✅ Impresión enviada via USB directo");
        return;
      }
    } catch (error) {
      console.log(`❌ Error en ${device}: ${error.message}`);
    }
  }
  
  console.log("⚠️ No se encontraron dispositivos USB, probando método alternativo...");
  fallback();
}

function tryWindowsPowerShell(text, fallback) {
  console.log("📄 Intentando PowerShell de Windows...");
  
  // Crear script PowerShell temporal
  const psScript = `
    $content = @"
${text.replace(/"/g, '`"')}
"@

    # Buscar impresoras térmicas
    $thermalPrinters = Get-Printer | Where-Object { 
      $_.Name -like "*thermal*" -or 
      $_.Name -like "*receipt*" -or 
      $_.Name -like "*pos*" -or
      $_.Name -like "*80mm*"
    }
    
    if ($thermalPrinters) {
      $printer = $thermalPrinters[0]
      Write-Host "Enviando a impresora: $($printer.Name)"
      $content | Out-Printer -Name $printer.Name
      Write-Host "Impresion enviada correctamente"
    } else {
      Write-Host "No se encontraron impresoras termicas"
      # Intentar con impresora predeterminada
      $content | Out-Printer
      Write-Host "Enviado a impresora predeterminada"
    }
  `;
  
  // Ejecutar PowerShell desde WSL
  const psProcess = spawn('powershell.exe', ['-Command', psScript], {
    stdio: ['pipe', 'pipe', 'pipe']
  });
  
  psProcess.stdout.on('data', (data) => {
    console.log(`PowerShell: ${data.toString().trim()}`);
  });
  
  psProcess.stderr.on('data', (data) => {
    console.error(`PowerShell Error: ${data.toString().trim()}`);
  });
  
  psProcess.on('close', (code) => {
    if (code === 0) {
      console.log("✅ Impresión enviada via PowerShell");
    } else {
      console.log("❌ PowerShell falló, usando método de respaldo...");
      fallback();
    }
  });
  
  psProcess.on('error', (error) => {
    console.log(`❌ Error ejecutando PowerShell: ${error.message}`);
    fallback();
  });
}

function saveToSharedFile(text) {
  // Guardar en directorio compartido entre WSL y Windows
  const sharedPaths = [
    '/mnt/c/temp/thermal_print.txt',
    '/tmp/thermal_print.txt'
  ];
  
  for (const path of sharedPaths) {
    try {
      fs.writeFileSync(path, text);
      console.log(`📝 Contenido guardado en: ${path}`);
      console.log("💡 Puedes enviar este archivo manualmente a la impresora");
      break;
    } catch (error) {
      console.log(`❌ No se pudo escribir en ${path}`);
    }
  }
}
