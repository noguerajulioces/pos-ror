class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :edit, :update, :destroy ]

  def index
    @orders = Order.includes(:user, :payment_method, :customer).paginate(page: params[:page], per_page: 15)
  end

  def show
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
      redirect_to @order, notice: "Orden creada exitosamente."
    else
      @payment_methods = PaymentMethod.active
      @customers = Customer.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: "Orden actualizada exitosamente."
    else
      @payment_methods = PaymentMethod.active
      @customers = Customer.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.cancelled!
    redirect_to orders_path, notice: "Orden cancelada exitosamente."
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:order_date, :status, :total_amount, :payment_method_id, :customer_id, :order_type)
  end
end
