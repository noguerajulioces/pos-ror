# app/services/print_service.rb
class PrintService
  def self.print_message(message = "Mensaje por defecto")
    script_path = Rails.root.join("scripts/print.js").to_s
    command = [ "node", script_path, message ].shelljoin

    pid = Process.spawn(command)
    Process.detach(pid)  # Esto permite que el proceso se ejecute en segundo plano sin esperar su finalización

    Rails.logger.info "Proceso de impresión iniciado en segundo plano (PID: #{pid})"
  end
end
