# app/controllers/pos_controller.rb
class PosController < ApplicationController
  layout "pos"

  #before_action :authenticate_user!
  #before_action :ensure_cash_register_open

  def show
    # Aquí puedes cargar los datos que necesites en la vista
    # Por ejemplo, si quieres mostrar la lista de productos:
    @products = Product.all
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
