# app/services/print_service.rb
class PrintService
  def self.print_order(order_id, template = 'default')
    order = Order.find(order_id)

    if order.receipt_number.blank?
      # Obtener el valor actual
      current_value = Setting.get('company_invoice_number') # Ej: "001-002-0001516"

      # Separar el prefijo y el número
      prefix = current_value[0..7]                     # "001-002-"
      number = current_value[8..-1].to_i               # 1516

      # Sumar 1 y formatear con ceros a la izquierda
      new_number = number + 1
      formatted_number = "#{prefix}#{format('%07d', new_number)}"

      # Guardar en la orden y actualizar Setting
      order.update!(receipt_number: current_value)
      Setting.set('company_invoice_number', formatted_number)
    end

    receipt_text = ApplicationController.render(
      template: "orders/print_templates/#{template}",
      locals: { order: order },
      layout: false
    )

    # Usar la gema Ruby escpos en lugar de Node.js
    print_with_escpos(receipt_text, order_id)

    Rails.logger.info "Impresión procesada para orden #{order_id}"
  rescue => e
    Rails.logger.error "Error al imprimir la orden #{order_id}: #{e.message}"
    raise
  end

  private

  def self.print_with_escpos(text, order_id = nil)
    # Limpiar HTML del texto
    clean_text = clean_html_text(text)

    begin
      # Intentar imprimir con escpos
      printer = Escpos::Printer.new
      printer << clean_text
      printer.cut!

      # Buscar dispositivos de impresión
      thermal_devices = find_thermal_devices

      if thermal_devices.any?
        thermal_devices.each do |device|
          begin
            # Si es la impresora FTX, usar método especial
            if device == 'WINDOWS_PRINTER_FTX' || device.start_with?('/dev/bus/usb/')
              success = print_to_ftx_device(printer.to_escpos, device)
              if success
                Rails.logger.info '✅ Impresión enviada a FTX TDRO58U via método especial'
                return true
              else
                Rails.logger.warn '❌ Error enviando a FTX TDRO58U via método especial'
                next
              end
            else
              # Método normal para otros dispositivos
              File.open(device, 'w') { |f| f.write printer.to_escpos }
              Rails.logger.info "✅ Impresión enviada a #{device}"
              return true
            end
          rescue => e
            Rails.logger.warn "❌ Error en dispositivo #{device}: #{e.message}"
            next
          end
        end
      end

      # Si no se pudo imprimir en ningún dispositivo, guardar como respaldo
      fallback_print(clean_text, order_id)

    rescue => e
      Rails.logger.error "Error con gema escpos: #{e.message}"
      fallback_print(clean_text, order_id)
    end
  end

  def self.clean_html_text(html_text)
    # Remover HTML y limpiar el texto para impresión térmica
    clean_text = html_text
      .gsub(/<!--.*?-->/m, '') # Remover comentarios HTML
      .gsub(/<br\s*\/?>/i, "\n") # <br> -> salto de línea
      .gsub(/<\/p>/i, "\n") # </p> -> salto de línea
      .gsub(/<[^>]*>/, '') # Remover todas las etiquetas HTML
      .gsub(/&nbsp;/, ' ') # &nbsp; -> espacio
      .gsub(/&amp;/, '&') # &amp; -> &
      .gsub(/&lt;/, '<') # &lt; -> <
      .gsub(/&gt;/, '>') # &gt; -> >
      .gsub(/\n\s*\n/, "\n") # Múltiples saltos -> uno solo
      .strip

    # Arreglar encoding para impresoras térmicas
    fix_encoding_for_thermal(clean_text)
  end

  def self.print_to_ftx_device(escpos_data, device_type = 'WINDOWS_PRINTER_FTX')
    # Método especializado para FTX TDRO58U
    begin
      # Crear archivo temporal en ubicación accesible desde Windows
      temp_file = "/mnt/c/temp/ftx_print_#{Time.now.to_i}.txt"

      # Convertir datos ESC/POS a texto plano para Windows
      clean_text = escpos_data.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
                              .gsub(/\e[@\[\]0-9;]*[a-zA-Z]/, '') # Remover códigos ESC/POS
                              .gsub(/[[:cntrl:]]/, '') # Remover caracteres de control
                              .strip

      File.write(temp_file, clean_text)
      Rails.logger.info "📄 Archivo temporal: #{temp_file}"

      # Intentar diferentes métodos de impresión via Windows
      windows_temp = temp_file.gsub('/mnt/c/', 'C:\\').gsub('/', '\\')

      if device_type == 'WINDOWS_PRINTER_FTX'
        # Métodos para impresora configurada en Windows (Generic / Text Only)
        methods = [
          # Método 1: PowerShell directo (el que funciona!)
          "powershell.exe -Command \"'#{clean_text.gsub("'", "''")}' | Out-Printer -Name 'Generic / Text Only'\"",
          # Método 2: PowerShell Get-Content
          "powershell.exe -Command \"Get-Content '#{windows_temp}' | Out-Printer -Name 'Generic / Text Only'\"",
          # Método 3: CMD copy a PRN
          "cmd.exe /c \"copy #{windows_temp} PRN\"",
          # Método 4: Buscar automáticamente la impresora
          "powershell.exe -Command \"'#{clean_text.gsub("'", "''")}' | Out-Printer -Name (Get-Printer | Where-Object {$_.Name -like '*Generic*' -or $_.Name -like '*Text*'} | Select-Object -First 1).Name\""
        ]
      else
        # Métodos para dispositivo USB directo
        methods = [
          "cat #{temp_file} > #{device_type} 2>/dev/null",
          "dd if=#{temp_file} of=#{device_type} 2>/dev/null",
          "sudo cat #{temp_file} > #{device_type} 2>/dev/null"
        ]
      end

      methods.each_with_index do |method, index|
        Rails.logger.info "🔄 FTX Windows método #{index + 1}"
        result = system(method)
        if result
          Rails.logger.info "✅ FTX Windows método #{index + 1} exitoso"
          File.delete(temp_file) if File.exist?(temp_file)
          return true
        end
      end

      File.delete(temp_file) if File.exist?(temp_file)
      false

    rescue => e
      Rails.logger.error "❌ Error en método FTX Windows: #{e.message}"
      false
    end
  end

  def self.fix_encoding_for_thermal(text)
    # Convertir caracteres especiales para impresoras térmicas
    text
      .encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      .gsub(/[áàâäã]/, 'a')
      .gsub(/[éèêë]/, 'e')
      .gsub(/[íìîï]/, 'i')
      .gsub(/[óòôöõ]/, 'o')
      .gsub(/[úùûü]/, 'u')
      .gsub(/[ÁÀÂÄÃ]/, 'A')
      .gsub(/[ÉÈÊË]/, 'E')
      .gsub(/[ÍÌÎÏ]/, 'I')
      .gsub(/[ÓÒÔÖÕ]/, 'O')
      .gsub(/[ÚÙÛÜ]/, 'U')
      .gsub(/ñ/, 'n')
      .gsub(/Ñ/, 'N')
      .gsub(/ç/, 'c')
      .gsub(/Ç/, 'C')
      .gsub(/[""„]/, '"')
      .gsub(/[''‚]/, "'")
      .gsub(/[–—]/, '-')
      .gsub(/…/, '...')
      .gsub(/€/, 'EUR')
      .gsub(/£/, 'GBP')
      .gsub(/¥/, 'YEN')
      .gsub(/[^\x00-\x7F]/, '?') # Reemplazar cualquier carácter no-ASCII restante
  end

  def self.detect_ftx_usb_device
    # Detectar impresora FTX desde Windows (ya configurada)
    begin
      # Método 1: Buscar en impresoras instaladas de Windows
      printers_output = `powershell.exe -Command "Get-Printer | Select-Object Name" 2>/dev/null`.strip
      
      if printers_output.include?('FTX') || printers_output.include?('TDR') || printers_output.include?('Generic / Text Only')
        Rails.logger.info '🖨️ Impresora térmica encontrada en Windows (Generic / Text Only)'
        return [ 'WINDOWS_PRINTER_FTX' ]  # Marcador especial para usar Windows
      end

      # Método 2: Buscar por USB si no está en Windows
      lsusb_output = `lsusb 2>/dev/null`.strip
      ftx_line = lsusb_output.lines.find { |line| line.include?('2aaf:6001') || line.include?('FTX') }

      if ftx_line
        # Extraer Bus y Device del formato: "Bus 001 Device 002: ID 2aaf:6001 FTX TDRO58U"
        if ftx_line.match(/Bus (\d+) Device (\d+)/)
          bus = $1.rjust(3, '0')
          device = $2.rjust(3, '0')
          usb_path = "/dev/bus/usb/#{bus}/#{device}"
          Rails.logger.info "🔍 FTX detectada por USB: #{usb_path}"
          return [ usb_path ]
        end
      end

      Rails.logger.warn '⚠️ FTX TDRO58U no detectada'
      []

    rescue => e
      Rails.logger.error "❌ Error detectando FTX: #{e.message}"
      []
    end
  end

  def self.find_thermal_devices
    # Buscar dispositivos de impresión térmica comunes
    potential_devices = [
      # Dispositivos USB estándar
      '/dev/usb/lp0', '/dev/usb/lp1', '/dev/usb/lp2', '/dev/usb/lp3',
      # Dispositivos serie USB
      '/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyUSB2', '/dev/ttyUSB3',
      # Dispositivos ACM (Abstract Control Model)
      '/dev/ttyACM0', '/dev/ttyACM1', '/dev/ttyACM2', '/dev/ttyACM3',
      # Dispositivos de impresión alternativos
      '/dev/lp0', '/dev/lp1', '/dev/lp2',
      # Para impresoras FTX y similares
      '/dev/usb/hiddev0', '/dev/usb/hiddev1',
      '/dev/hidraw0', '/dev/hidraw1', '/dev/hidraw2',
      # Detectar dinámicamente la impresora FTX TDRO58U
      *detect_ftx_usb_device
    ]

    available_devices = potential_devices.select { |device| File.exist?(device) }

    if available_devices.empty?
      Rails.logger.warn '⚠️ No se encontraron dispositivos de impresión térmica'
      Rails.logger.info "💡 Dispositivos buscados: #{potential_devices.join(', ')}"

      # Debug adicional para FTX TDR058U
      Rails.logger.info '🔍 Debug adicional:'
      Rails.logger.info "   - lsusb: #{`lsusb 2>/dev/null`.strip}"
      Rails.logger.info "   - /dev/usb/: #{`ls -la /dev/usb/ 2>/dev/null`.strip}"
      Rails.logger.info "   - /dev/hidraw*: #{`ls -la /dev/hidraw* 2>/dev/null`.strip}"
    else
      Rails.logger.info "📄 Dispositivos encontrados: #{available_devices.join(', ')}"
    end

    available_devices
  end

  def self.fallback_print(text, order_id = nil)
    # Guardar en archivo como respaldo
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_file = Rails.root.join('tmp', "thermal_backup_#{order_id || timestamp}.txt")

    File.write(backup_file, text)

    Rails.logger.warn "📝 Impresión guardada en: #{backup_file}"
    Rails.logger.info "💡 Para debug: cat #{backup_file}"
    Rails.logger.info '💡 Verifica dispositivos: ls -la /dev/usb/lp* /dev/ttyUSB* 2>/dev/null'
  end
end
