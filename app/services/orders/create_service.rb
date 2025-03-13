module Orders
  class CreateService
    attr_reader :cart, :params, :current_user, :session, :payment_method_service, :stock_service

    def initialize(cart:, params:, current_user:, session:,
                  payment_method_service: nil,
                  stock_service: nil)
      @cart = cart || []
      @params = params
      @current_user = current_user
      @session = session
      @payment_method_service = payment_method_service || PaymentMethodService.new
      @stock_service = stock_service || StockService.new
    end

    def call
      return failure_response("El carrito está vacío") if cart.empty?

      ActiveRecord::Base.transaction do
        order = create_order
        create_order_items(order)

        # Reduce stock if the order is completed
        stock_service.reduce_stock(order) if order.status == Order::STATUSES[:completed]

        clear_session_data
        success_response(order.id)
      end
    rescue => e
      failure_response(e.message)
    end

    private

    def create_order
      order = Order.new(order_attributes)
      raise order.errors.full_messages.join(", ") unless order.save
      order
    end

    def order_attributes
      {
        order_date: Time.current,
        status: params[:status] || Order::STATUSES[:on_hold],
        total_amount: cart_calculator.totals[:total],
        user_id: current_user.id,
        payment_method_id: payment_method_id,
        customer_id: session[:customer_id].presence,
        order_type: order_type,
        discount_percentage: session[:discount_percentage],
        discount_reason: session[:discount_reason]
      }
    end

    def order_type
      type = params[:order_type].presence || "in_store"
      Order.order_types.keys.include?(type) ? type : "in_store"
    end

    def payment_method_id
      params[:payment_method_id].presence || payment_method_service.default_payment_method.id
    end

    def create_order_items(order)
      cart.each do |item|
        order.order_items.create!(
          product_id: item["product_id"],
          quantity: item["quantity"],
          price: item["price"],
          subtotal: item["price"].to_f * item["quantity"].to_i
        )
      end
    end

    def clear_session_data
      session[:cart] = []
      session[:discount] = 0
      session[:discount_percentage] = nil
      session[:discount_reason] = nil
    end

    def cart_calculator
      @cart_calculator ||= Orders::CartCalculator.new(
        cart: cart,
        discount: session[:discount].to_f
      )
    end

    def success_response(order_id)
      { success: true, order_id: order_id }
    end

    def failure_response(error_message)
      { success: false, error: error_message }
    end
  end
end
