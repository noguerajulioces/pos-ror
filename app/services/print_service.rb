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
            File.open(device, 'w') { |f| f.write printer.to_escpos }
            Rails.logger.info "✅ Impresión enviada a #{device}"
            return true
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
      # Dispositivo USB directo para FTX TDRO58U (Bus 001 Device 002)
      '/dev/bus/usb/001/002'
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
