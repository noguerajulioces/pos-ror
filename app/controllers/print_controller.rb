class PrintController < ApplicationController
  def print_message
    PrintServiceNew.print_order(params[:order_id])

    redirect_back(fallback_location: orders_path, notice: 'Orden enviada a impresión')
  end
end
