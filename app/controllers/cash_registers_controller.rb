class CashRegistersController < ApplicationController
  def create
    @cash_register = CashRegister.new(cash_register_params)
    @cash_register.user = current_user
    @cash_register.open_at = Time.current
    @cash_register.status = 'open'

    if @cash_register.save
      render json: { success: true }
    else
      render json: { success: false, errors: @cash_register.errors.full_messages }
    end
  end

  private

  def cash_register_params
    params.require(:cash_register).permit(:initial_amount)
  end
end
