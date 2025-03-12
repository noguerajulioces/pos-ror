class OrderPaymentsController < ApplicationController
  before_action :set_order_payment, only: [:show, :destroy]
  before_action :set_order, only: [:new, :create]

  def index
    @order_payments = OrderPayment.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @order_payment = OrderPayment.new(order_id: params[:order_id])
    @payment_methods = PaymentMethod.all
  end

  def create
    @order_payment = OrderPayment.new(order_payment_params)
    
    respond_to do |format|
      if @order_payment.save
        format.html { redirect_to order_path(@order_payment.order), notice: "Pago registrado correctamente." }
        format.json { render :show, status: :created, location: @order_payment }
      else
        @payment_methods = PaymentMethod.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    order = @order_payment.order
    @order_payment.destroy
    
    respond_to do |format|
      format.html { redirect_to order_path(order), notice: "Pago eliminado correctamente." }
      format.json { head :no_content }
    end
  end

  private
    def set_order_payment
      @order_payment = OrderPayment.find(params[:id])
    end

    def set_order
      @order = Order.find(params[:order_id])
    end

    def order_payment_params
      params.require(:order_payment).permit(:order_id, :payment_method_id, :amount, :payment_date, :reference_number, :notes)
    end
end