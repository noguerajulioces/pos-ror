module Orders
  class CreateService
    attr_reader :cart, :params, :current_user, :session

    def initialize(cart:, params:, current_user:, session:)
      @cart = cart || []
      @params = params
      @current_user = current_user
      @session = session
    end

    def call
      return failure_response("El carrito está vacío") if cart.empty?

      # Cash register validation is commented out as it was in the original code
      # return failure_response("No hay caja abierta") unless cash_register_open?

      ActiveRecord::Base.transaction do
        order = create_order
        create_order_items(order)

        # Reduce stock if the order is completed
        reduce_stock(order) if order.status == Order::STATUSES[:completed]

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
      # Ensure order_type is one of the valid enum values
      order_type = params[:order_type].presence || "in_store"
      # Validate that the order_type is one of the valid enum values
      order_type = "in_store" unless Order.order_types.keys.include?(order_type)

      {
        order_date: Time.current,
        status: params[:status] || Order::STATUSES[:on_hold],
        total_amount: cart_calculator.totals[:total],
        user_id: current_user.id,
        payment_method_id: default_payment_method.id,
        customer_id: session[:customer_id].presence,
        order_type: order_type,
        discount_percentage: session[:discount_percentage],
        discount_reason: session[:discount_reason]
      }
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

    # New method to reduce stock for completed orders
    def reduce_stock(order)
      order.order_items.each do |item|
        product = Product.find(item.product_id)
        new_stock = (product.stock || 0) - item.quantity

        # Prevent negative stock (optional, remove if you want to allow negative stock)
        new_stock = 0 if new_stock < 0

        product.update!(stock: new_stock)
      end
    end

    def clear_session_data
      session[:cart] = []
      session[:discount] = 0
      session[:discount_percentage] = nil
      session[:discount_reason] = nil
    end

    def default_payment_method
      PaymentMethod.find_or_create_by(name: "Efectivo") do |payment_method|
        payment_method.description = "Pago en efectivo"
        payment_method.active = true
      end
    end

    def cash_register_open?
      CashRegister.open.exists?
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
