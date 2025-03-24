class CashRegistersController < ApplicationController
  before_action :authenticate_user!

  def new
    @cash_register = CashRegister.new
  end

  def create
    @cash_register = current_user.cash_registers.new(cash_register_params)
    @cash_register.open_at = Time.current
    @cash_register.status = 'open'

    if @cash_register.save
      redirect_to pos_path, notice: 'Caja abierta correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def close
    @cash_register = current_user.cash_registers.open.first
    
    if @cash_register.nil?
      # We'll handle this in the view
      return
    end
    
    # Calculate sales total without relying on cash_register_id
    @sales_total = Order.where(user_id: current_user.id, status: 'completed')
                       .where('created_at >= ?', @cash_register.open_at)
                       .sum(:total_amount) || 0
                       
    # Calculate expected amount
    @expected_amount = @cash_register.initial_amount + @sales_total
    
    render layout: false
  end

  def process_close
    @cash_register = current_user.cash_registers.open.find(params[:id])

    if @cash_register.close!(params[:cash_register][:final_amount])
      redirect_to pos_path, notice: 'Caja cerrada correctamente.'
    else
      render :close, status: :unprocessable_entity
    end
  end

  private

  def cash_register_params
    params.require(:cash_register).permit(:initial_amount)
  end
end
