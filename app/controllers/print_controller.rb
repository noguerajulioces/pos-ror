class PrintController < ApplicationController
  def print_message
    message = params[:message] || "Mensaje por defecto"
    PrintService.print_message(message)
    render plain: "Mensaje impreso"
  end
end
