class PrintController < ApplicationController
  def print_message
    message = params[:message] || "Hola, este es un mensaje de prueba"
    # Construye el comando: ajusta la ruta al script según la estructura de tu proyecto
    command = "node \"#{Rails.root.join('scripts/print.js')}\" \"#{message}\""

    # Run the command in the background
    Thread.new do
      system(command)
    end

    # Return immediately without waiting for the print job to complete
    render plain: "Solicitud de impresión enviada."
  end
end
