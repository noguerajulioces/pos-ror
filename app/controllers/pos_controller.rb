# app/controllers/pos_controller.rb
class PosController < ApplicationController
  layout "pos"

  # before_action :authenticate_user!
  # before_action :ensure_cash_register_open

  def show
    # Aquí puedes cargar los datos que necesites en la vista
    # Por ejemplo, si quieres mostrar la lista de productos:
    @products = Product.all
    @categories = Category.where(parent_id: nil)
  end


  def order_type_modal
    render partial: "order_type_modal"
  end

  # Add this method to your PosController
def customer_search_modal
  render partial: 'customer_search_modal'
end

def update_order_type
  @order_type = params[:type]
  respond_to do |format|
    format.turbo_stream {
      render turbo_stream: turbo_stream.update("order_type", @order_type.titleize)
    }
  end
end

  private

  def ensure_cash_register_open
    # Verifica que haya una caja abierta
    # (asumiendo que tienes un modelo CashRegister con un scope :open)
    @cash_register = CashRegister.open.first
    unless @cash_register
      redirect_to new_cash_register_path, notice: "Por favor, abre la caja antes de continuar."
    end
  end
end
