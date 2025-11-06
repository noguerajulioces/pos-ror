class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :edit, :update, :destroy, :assign_delivery_user, :print_preview, :receipt_preview ]

  def receipt_preview
    render template: 'orders/print_templates/default', layout: 'application' # o 'print' si tenés un layout para recibos
  end

  def print_preview
    render layout: 'print'
  end

  def index
    @q = Order.ransack(params[:q])
    @orders = @q.result(distinct: true)
              .includes(:customer, :payment_method, :delivery_user, :table)
              .order(order_date: :desc)
              .paginate(page: params[:page], per_page: 10)
    @delivery_users = User.joins(:roles)
                         .where(roles: { name: 'Delivery' })
                         .where(account_id: current_user.account_id)
                         .active
                         .order(:name)
  end

  def show
    @order = Order.includes(:table).find(params[:id])
    @order_items = @order.order_items.includes(:product)
  end

  def new
    @order = Order.new
    @order.order_date = Time.current
    @payment_methods = PaymentMethod.active
    @customers = Customer.all
  end

  def edit
    @payment_methods = PaymentMethod.active
    @customers = Customer.all
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user

    if @order.save
      redirect_to @order, notice: 'Orden creada exitosamente.'
    else
      @payment_methods = PaymentMethod.active
      @customers = Customer.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Orden actualizada exitosamente.'
    else
      @payment_methods = PaymentMethod.active
      @customers = Customer.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.cancelled!
    redirect_to orders_path, notice: 'Orden cancelada exitosamente.'
  end

  def assign_delivery_user
    if @order.update(delivery_user_id: params[:delivery_user_id])
      respond_to do |format|
        format.json { render json: { success: true, message: 'Repartidor asignado exitosamente.' } }
        format.turbo_stream { render turbo_stream: turbo_stream.remove('modal') }
        format.html { redirect_to @order, notice: 'Repartidor asignado exitosamente.' }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: 'Error al asignar el repartidor.' }, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', partial: 'orders/modals/assign_delivery'), status: :unprocessable_entity }
        format.html { redirect_to @order, alert: 'Error al asignar el repartidor.' }
      end
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:order_date, :status, :total_amount, :payment_method_id, :customer_id, :order_type)
  end
end
