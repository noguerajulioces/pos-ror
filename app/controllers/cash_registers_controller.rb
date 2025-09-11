class CashRegistersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_super_user_access, only: [ :show ]

  def index
    if params[:q] && params[:q][:open_at_lteq].present?
      params[:q][:open_at_lteq] = Time.zone.parse(params[:q][:open_at_lteq]).end_of_day
    end

    @q = CashRegister.includes(:user).order(created_at: :desc).ransack(params[:q])
    @cash_registers = @q.result(distinct: true).paginate(page: params[:page], per_page: 10)
  end

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
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Caja cerrada correctamente.' }
      end
    else
      # Calculate values again in case of error
      @sales_total = Order.where(user_id: current_user.id, status: 'completed')
                         .where('created_at >= ?', @cash_register.open_at)
                         .sum(:total_amount) || 0
      @expected_amount = @cash_register.initial_amount + @sales_total

      render :close, status: :unprocessable_entity
    end
  end

  def show
    @cash_register = CashRegister.includes(:user, cash_movements: []).find(params[:id])

    order_time_range = @cash_register.open_at..(@cash_register.close_at || Time.current)

    @orders = Order.where(
      user_id: @cash_register.user_id,
      created_at: order_time_range,
      status: 'completed'
    ).includes(:customer, :order_payments, order_payments: :payment_method)

    @cash_summary = calculate_cash_summary(@cash_register)

    @payment_breakdown = calculate_payment_breakdown(@orders)

    @ticket_metrics = calculate_ticket_metrics(@orders)

    @cash_movements = @cash_register.cash_movements.order(created_at: :desc)
  end

  private

  def cash_register_params
    params.require(:cash_register).permit(:initial_amount)
  end

  def check_super_user_access
    unless current_user.super_user?
      redirect_to cash_registers_path, alert: 'No tienes permisos para acceder a esta información.'
    end
  end

  # MÉTRICA 1: Resumen de Caja
  def calculate_cash_summary(cash_register)
    order_time_range = cash_register.open_at..(cash_register.close_at || Time.current)

    # Ventas totales del período
    total_sales = Order.where(
      user_id: cash_register.user_id,
      created_at: order_time_range,
      status: 'completed'
    ).sum(:total_amount) || 0

    # Movimientos de caja
    cash_movements = cash_register.cash_movements
    total_ingresos = cash_movements.where(movement_type: 'ingreso').sum(:amount) || 0
    total_egresos = cash_movements.where(movement_type: 'egreso').sum(:amount) || 0

    # Cálculos principales
    saldo_inicial = cash_register.initial_amount
    saldo_esperado = saldo_inicial + total_sales + total_ingresos - total_egresos
    saldo_real = cash_register.final_amount
    diferencia = saldo_real.present? ? (saldo_real - saldo_esperado) : nil

    {
      saldo_inicial: saldo_inicial,
      ingresos_ventas: total_sales,
      ingresos_extra: total_ingresos,
      egresos: total_egresos,
      saldo_esperado: saldo_esperado,
      saldo_real: saldo_real,
      diferencia: diferencia,
      cuadra: diferencia&.zero? || diferencia.nil?
    }
  end

  # MÉTRICA 2: Ventas por Método de Pago
  def calculate_payment_breakdown(orders)
    # Obtener todos los pagos de las órdenes del período
    order_ids = orders.pluck(:id)
    payments = OrderPayment.joins(:payment_method)
                          .where(order_id: order_ids, status: 'completed')
                          .group('payment_methods.name')
                          .sum(:amount)

    total_amount = payments.values.sum

    breakdown = payments.map do |payment_method_name, amount|
      percentage = total_amount > 0 ? (amount * 100.0 / total_amount).round(1) : 0
      {
        name: payment_method_name,
        amount: amount,
        percentage: percentage
      }
    end.sort_by { |item| -item[:amount] } # Ordenar por monto descendente

    {
      breakdown: breakdown,
      total: total_amount
    }
  end

  # MÉTRICA 3: Ticket Promedio
  def calculate_ticket_metrics(orders)
    total_tickets = orders.count
    total_sales = orders.sum(:total_amount) || 0
    ticket_promedio = total_tickets > 0 ? (total_sales / total_tickets).round(0) : 0

    {
      total_tickets: total_tickets,
      total_sales: total_sales,
      ticket_promedio: ticket_promedio
    }
  end
end
