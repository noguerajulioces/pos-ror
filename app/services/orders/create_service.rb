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
      return failure_response('El carrito está vacío') if cart.empty?

      ActiveRecord::Base.transaction do
        order = create_order
        create_order_items(order)

        # Only create payment if order is completed
        create_order_payment(order) if order.status == Order::STATUSES[:completed]

        # Reduce stock if the order is completed
        if order.status == Order::STATUSES[:completed]
          StockManager.update_stock_from_order(order)
        end

        clear_session_data
        success_response(order.id)
      end
    rescue => e
      failure_response(e.message)
    end

    private


    def create_order
      # Check if we're updating an existing on-hold order
      if session[:on_hold_order_id].present?
        order = Order.find_by(id: session[:on_hold_order_id], status: 'on_hold')
        if order
          # Delete existing order items and recreate them with current cart
          order.order_items.destroy_all

          # Update order attributes
          order.assign_attributes(order_attributes)
          raise order.errors.full_messages.join(', ') unless order.save
          return order
        end
      end

      # Create new order
      order = Order.new(order_attributes)
      raise order.errors.full_messages.join(', ') unless order.save
      order
    end

    def order_attributes
      # Calculate the correct total amount (including delivery if present)
      base_total = cart_calculator.totals[:total]
      delivery_amount = session[:delivery_amount].to_f || 0
      final_total = base_total + delivery_amount

      {
        order_date: Time.current,
        status: params[:status] || Order::STATUSES[:on_hold],
        total_amount: final_total,
        user_id: current_user.id,
        payment_method_id: payment_method_id,
        customer_id: session[:customer_id].presence,
        order_type: order_type,
        table_id: order_type == 'in_store' ? session[:table_id].presence : nil,
        discount_percentage: session[:discount_percentage],
        discount_reason: session[:discount_reason],
        delivery_user_id: session[:delivery_user_id].presence,
        delivery_amount: delivery_amount,
        notes: session[:order_notes]
      }
    end

    def order_type
      type = params[:order_type].presence || 'in_store'
      Order.order_types.keys.include?(type) ? type : 'in_store'
    end

    def payment_method_id
      params[:payment_method_id].presence || payment_method_service.default_payment_method.id
    end

    def create_order_items(order)
      cart.each do |item|
        order.order_items.create!(
          product_id: item['product_id'],
          quantity: item['quantity'],
          price: item['price'],
          subtotal: item['price'].to_f * item['quantity'].to_f
        )
      end
    end

    def create_order_payment(order)
      OrderPayment.create!(
        order: order,
        payment_method_id: payment_method_id,
        amount: order.total_amount,
        payment_date: Time.current,
        reference_number: nil,
        notes: 'Pago realizado desde POS'
      )
    end

    def clear_session_data
      session[:cart] = []
      session[:discount] = 0
      session[:discount_percentage] = nil
      session[:discount_reason] = nil
      session[:customer_id] = nil
      session[:customer_name] = nil
      session[:delivery_user_id] = nil
      session[:delivery_user_name] = nil
      session[:delivery_amount] = 0
      session[:on_hold_order_id] = nil
      session[:order_notes] = nil
      session[:table_id] = nil
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
