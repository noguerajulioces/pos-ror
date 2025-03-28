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

    temp_file = Rails.root.join('tmp', "order_#{order_id}_print.txt")
    File.write(temp_file, receipt_text)

    script_path = Rails.root.join('scripts', 'print.js').to_s
    node_path = `which node`.strip.presence || 'node'
    command = [ node_path, script_path, temp_file.to_s ].shelljoin

    pid = Process.spawn(command)
    Process.detach(pid)

    Rails.logger.info "Proceso de impresión iniciado en segundo plano (PID: #{pid})"
  rescue => e
    Rails.logger.error "Error al imprimir la orden #{order_id}: #{e.message}"
    raise
  end
end
