# app/services/print_service_new.rb
class PrintServiceNew
  def self.print_order(order_id, template = 'default')
    order = Order.find(order_id)

    # Generar número de recibo si no existe
    if order.receipt_number.blank?
      current_value = Setting.get('company_invoice_number')
      prefix = current_value[0..7]
      number = current_value[8..-1].to_i
      new_number = number + 1
      formatted_number = "#{prefix}#{format('%07d', new_number)}"

      order.update!(receipt_number: current_value)
      Setting.set('company_invoice_number', formatted_number)
    end

    # Generar el contenido del recibo
    receipt_html = ApplicationController.render(
      template: "orders/print_templates/#{template}",
      locals: { order: order },
      layout: false
    )

    # Limpiar HTML y convertir a texto plano
    clean_text = clean_html_for_printing(receipt_html)

    # Intentar imprimir
    if print_to_thermal_printer(clean_text, order_id)
      Rails.logger.info "✅ Impresión exitosa para orden #{order_id}"
    else
      Rails.logger.warn "⚠️ Impresión guardada como respaldo para orden #{order_id}"
    end

  rescue => e
    Rails.logger.error "❌ Error al imprimir la orden #{order_id}: #{e.message}"
    raise
  end

  private

  def self.clean_html_for_printing(html_text)
    # Limpiar HTML y preparar para impresión
    clean_text = html_text
      .gsub(/<!--.*?-->/m, '')           # Remover comentarios HTML
      .gsub(/<br\s*\/?>/i, "\n")         # <br> -> salto de línea
      .gsub(/<\/p>/i, "\n")              # </p> -> salto de línea
      .gsub(/<[^>]*>/, '')               # Remover etiquetas HTML
      .gsub(/&nbsp;/, ' ')               # &nbsp; -> espacio
      .gsub(/&amp;/, '&')                # &amp; -> &
      .gsub(/&lt;/, '<')                 # &lt; -> <
      .gsub(/&gt;/, '>')                 # &gt; -> >
      .gsub(/\n\s*\n/, "\n")             # Múltiples saltos -> uno
      .strip

    # Limpiar caracteres especiales para impresión térmica
    clean_text
      .encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      .gsub(/[áàâäã]/, 'a').gsub(/[éèêë]/, 'e').gsub(/[íìîï]/, 'i')
      .gsub(/[óòôöõ]/, 'o').gsub(/[úùûü]/, 'u').gsub(/ñ/, 'n')
      .gsub(/[ÁÀÂÄÃ]/, 'A').gsub(/[ÉÈÊË]/, 'E').gsub(/[ÍÌÎÏ]/, 'I')
      .gsub(/[ÓÒÔÖÕ]/, 'O').gsub(/[ÚÙÛÜ]/, 'U').gsub(/Ñ/, 'N')
      .gsub(/[^\x00-\x7F]/, '?')         # Caracteres no-ASCII -> ?
  end

  def self.print_to_thermal_printer(text, order_id = nil)
    # Método basado en lo que SABEMOS que funciona
    begin
      Rails.logger.info '🖨️ Iniciando impresión térmica...'

      # Los métodos que funcionaron en tu prueba
      methods = [
        "powershell.exe -Command \"'#{text.gsub("'", "''")}' | Out-Printer -Name 'Generic / Text Only'\"",
        "cmd.exe /c \"echo #{text.gsub('"', '\"')} > PRN\"",
        "powershell.exe -Command \"'#{text.gsub("'", "''")}' | Out-Printer -Name (Get-Printer | Where-Object {\\$_.Name -like '*Generic*'} | Select-Object -First 1).Name\""
      ]

      methods.each_with_index do |method, index|
        Rails.logger.info "🔄 Probando método #{index + 1}..."

        result = system(method)

        if result
          Rails.logger.info "✅ Método #{index + 1} exitoso - Impresión enviada"
          return true
        else
          Rails.logger.warn "❌ Método #{index + 1} falló"
        end
      end

      # Si todos los métodos fallaron
      Rails.logger.warn '⚠️ Todos los métodos de impresión fallaron'
      save_backup(text, order_id)
      false

    rescue => e
      Rails.logger.error "❌ Error en impresión térmica: #{e.message}"
      save_backup(text, order_id)
      false
    end
  end

  def self.print_test
    # Crear contenido de prueba usando configuraciones actuales
    line_width = Setting.get('printer_line_width_chars').to_i

    test_content = <<~TEXT
      #{"=" * line_width}
      #{"PRUEBA DE IMPRESION".center(line_width)}
      #{"=" * line_width}

      Fecha: #{Time.current.strftime('%d/%m/%Y %H:%M')}

      Configuración actual:
      - Ancho: #{line_width} caracteres
      - Impresora: #{Setting.get('printer_windows_name')}
      - Líneas antes corte: #{Setting.get('printer_lines_before_cut')}

      ¡Si ves este mensaje, la
      configuración funciona correctamente!

      #{"=" * line_width}
    TEXT

    # Imprimir usando el método principal
    print_to_thermal_printer(test_content, 'test')
  end

  def self.save_backup(text, order_id = nil)
    # Guardar como respaldo
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_file = Rails.root.join('tmp', "thermal_backup_#{order_id || timestamp}.txt")

    File.write(backup_file, text)
    Rails.logger.info "📝 Respaldo guardado en: #{backup_file}"
  end
end
