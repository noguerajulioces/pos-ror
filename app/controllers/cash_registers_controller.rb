class CashRegistersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_super_user_access, only: [ :show ]
  before_action :check_mesero_access, except: [ :show ]
  
  def check_mesero_access
    if current_user.has_role?(:mesero)
      redirect_to pos_path, alert: 'Los meseros no tienen acceso a la gestión de caja.'
    end
  end

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

    # Usar el servicio para obtener los cálculos de cierre
    close_service = CashRegisterServices::CloseService.new(@cash_register, current_user)
    closing_data = close_service.closing_calculations

    @sales_total = closing_data[:sales_total]
    @expected_amount = closing_data[:expected_amount]

    render layout: false
  end

  def process_close
    @cash_register = current_user.cash_registers.open.find(params[:id])

    # Usar el servicio para cerrar la caja
    close_service = CashRegisterServices::CloseService.new(@cash_register, current_user)
    result = close_service.close!(params[:cash_register][:final_amount])

    if result[:success]
      respond_to do |format|
        format.html { redirect_to root_path, notice: result[:message] }
      end
    else
      # Recalcular valores en caso de error
      closing_data = close_service.closing_calculations
      @sales_total = closing_data[:sales_total]
      @expected_amount = closing_data[:expected_amount]

      render :close, status: :unprocessable_entity
    end
  end

  def show
    @cash_register = CashRegister.includes(:user, cash_movements: []).find(params[:id])

    # Usar el servicio para obtener todas las métricas
    analytics_service = CashRegisterServices::AnalyticsService.new(@cash_register)
    analytics_data = analytics_service.analytics

    # Asignar las métricas a variables de instancia para la vista
    @cash_summary = analytics_data[:cash_summary]
    @payment_breakdown = analytics_data[:payment_breakdown]
    @ticket_metrics = analytics_data[:ticket_metrics]

    # Datos adicionales
    @orders = analytics_data[:additional_data][:orders]
    @cash_movements = analytics_data[:additional_data][:cash_movements]
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
end
