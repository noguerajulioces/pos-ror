#!/usr/bin/env ruby

# Script especializado para impresora FTX TDRO58U
# Usa comandos del sistema para enviar datos via USB

require 'tempfile'

def print_to_ftx(text)
  puts "🖨️ Enviando a impresora FTX TDRO58U..."
  
  # Método 1: Usar echo con redirección
  begin
    # Crear archivo temporal con el texto
    temp_file = Tempfile.new('ftx_print')
    temp_file.write(text)
    temp_file.close
    
    # Intentar diferentes métodos de envío
    methods = [
      "cat #{temp_file.path} > /dev/bus/usb/001/002",
      "dd if=#{temp_file.path} of=/dev/bus/usb/001/002 2>/dev/null",
      "printf '#{text.gsub("'", "\\'")}' | tee /dev/bus/usb/001/002 >/dev/null"
    ]
    
    methods.each_with_index do |method, index|
      puts "🔄 Probando método #{index + 1}: #{method.split('|').first.strip}"
      
      result = system(method)
      if result
        puts "✅ Impresión enviada correctamente (método #{index + 1})"
        temp_file.unlink
        return true
      else
        puts "❌ Método #{index + 1} falló"
      end
    end
    
    temp_file.unlink
    
  rescue => e
    puts "❌ Error: #{e.message}"
  end
  
  # Método 2: Usar lp si está disponible
  begin
    puts "🔄 Probando comando lp..."
    system("echo '#{text.gsub("'", "\\'")}' | lp -d raw 2>/dev/null")
    puts "✅ Enviado via lp"
    return true
  rescue
    puts "❌ Comando lp no disponible"
  end
  
  # Método 3: Guardar como respaldo
  backup_file = "/tmp/ftx_backup_#{Time.now.to_i}.txt"
  File.write(backup_file, text)
  puts "📝 Guardado en: #{backup_file}"
  puts "💡 Prueba manualmente: cat #{backup_file} > /dev/bus/usb/001/002"
  
  return false
end

# Usar como script independiente
if __FILE__ == $0
  if ARGV.empty?
    text = "=== PRUEBA FTX TDRO58U ===\nFecha: #{Time.now}\nDispositivo: /dev/bus/usb/001/002\n=========================\n\n\n"
  else
    text = File.read(ARGV[0])
  end
  
  print_to_ftx(text)
end
