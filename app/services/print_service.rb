# app/services/print_service.rb
class PrintService
  def self.print_order(order_id, template = "default")
    order = Order.find(order_id)

    # Renderiza el template de texto plano.
    receipt_text = ApplicationController.render(
      template: "orders/print_templates/#{template}",
      locals: { order: order },
      layout: false
    )

    # Guarda el recibo en un archivo temporal
    temp_file = Rails.root.join("tmp", "order_#{order_id}_print.txt")
    File.write(temp_file, receipt_text)

    # Construye el comando para invocar el script Node.js
    require "shellwords"
    script_path = Rails.root.join("scripts", "print.js").to_s
    command = [ "node", script_path, temp_file.to_s ].shelljoin

    pid = Process.spawn(command)
    Process.detach(pid)
    Rails.logger.info "Proceso de impresión iniciado en segundo plano (PID: #{pid})"
  end
end
