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
        order, is_new = create_order
        create_order_items(order) if is_new

        # Only create payment if order is completed or pending payment with amount
        create_order_payment(order) if should_create_payment?(order)

        # Reduce stock if the order is completed, pending payment, or ON HOLD
        if [ Order::STATUSES[:completed], Order::STATUSES[:pending_payment], Order::STATUSES[:on_hold] ].include?(order.status)
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
          # REVERT stock before merging items
          StockManager.revert_stock_from_order(order)

          # Smart merge: update/create/delete items instead of destroy_all
          merge_order_items(order)

          # Update order attributes (excluding user_id to preserve the original creator)
          attributes = order_attributes.except(:user_id)
          order.assign_attributes(attributes)
          raise order.errors.full_messages.join(', ') unless order.save
          return [order, false]
        end
      end

      # Create new order
      order = Order.new(order_attributes)
      raise order.errors.full_messages.join(', ') unless order.save
      [order, true]
    end

    def merge_order_items(order)
      # Remove duplicate order_items (same product_id), keeping the one with highest kitchen_printed_quantity
      order.order_items.group_by(&:product_id).each do |_pid, items|
        next if items.size == 1
        keeper = items.max_by(&:kitchen_printed_quantity)
        items.reject { |i| i.id == keeper.id }.each(&:destroy!)
      end

      existing_items = order.order_items.reload.index_by(&:product_id)
      cart_product_ids = cart.map { |i| i['product_id'].to_i }

      # Update or create items from cart
      cart.each do |cart_item|
        product_id = cart_item['product_id'].to_i
        new_qty    = cart_item['quantity'].to_f

        if existing_items[product_id]
          # Item exists — update quantity, preserve kitchen_printed_quantity
          existing_items[product_id].update!(
            quantity: new_qty,
            price: cart_item['price'].to_f,
            subtotal: cart_item['price'].to_f * new_qty
          )
        else
          # New item — kitchen has not seen it yet
          order.order_items.create!(
            product_id: product_id,
            quantity: new_qty,
            price: cart_item['price'].to_f,
            subtotal: cart_item['price'].to_f * new_qty,
            kitchen_printed_quantity: 0
          )
        end
      end

      # Destroy items removed from cart
      existing_items.each do |product_id, item|
        item.destroy! unless cart_product_ids.include?(product_id)
      end
    end

    def order_attributes
      # Calculate the correct total amount (including delivery if present)
      base_total = cart_calculator.totals[:total]
      delivery_amount = session[:delivery_amount].to_f || 0
      final_total = base_total + delivery_amount

      # Meseros solo pueden crear órdenes en espera
      order_status = if current_user.has_role?(:mesero)
        Order::STATUSES[:on_hold]
      else
        params[:status] || Order::STATUSES[:on_hold]
      end

      {
        order_date: Time.current,
        status: order_status,
        total_amount: final_total,
        user_id: current_user.id,
        payment_method_id: order_payment_method_id,
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

    def order_payment_method_id
      # For any pending payment (credit sale), the order payment method is nil
      if params[:status] == Order::STATUSES[:pending_payment]
        return nil
      end

      transaction_payment_method_id
    end

    def transaction_payment_method_id
      params[:payment_method_id].presence || payment_method_service.default_payment_method.id
    end

    def create_order_items(order)
      cart.group_by { |i| i['product_id'].to_i }.each do |product_id, items|
        total_qty = items.sum { |i| i['quantity'].to_f }
        price     = items.first['price'].to_f
        order.order_items.create!(
          product_id: product_id,
          quantity:   total_qty,
          price:      price,
          subtotal:   price * total_qty,
          kitchen_printed_quantity: 0
        )
      end
    end

    def create_order_payment(order)
      amount_to_pay = params[:amount_received].to_f > 0 ? params[:amount_received].to_f : order.total_amount

      OrderPayment.create!(
        order: order,
        payment_method_id: transaction_payment_method_id,
        amount: amount_to_pay,
        payment_date: Time.current,
        reference_number: nil,
        notes: 'Pago realizado desde POS'
      )
    end

    def should_create_payment?(order)
      return true if order.status == Order::STATUSES[:completed]
      return true if order.status == Order::STATUSES[:pending_payment] && params[:amount_received].to_f > 0
      false
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
      session[:last_kitchen_print] = nil
    end

    def cart_calculator
      @cart_calculator ||= Orders::CartCalculator.new(
        cart: cart,
        global_discount: session[:discount].to_f,
        global_discount_percentage: session[:discount_percentage].to_f
      )
    end

    def success_response(order_id)
      order = Order.includes(order_items: :product).includes(:table, :customer).find(order_id)
      kitchen_items = order.order_items.select { |i| i.quantity > i.kitchen_printed_quantity }
      { success: true, order_id: order_id, kitchen_items: kitchen_items, order: order }
    end

    def failure_response(error_message)
      { success: false, error: error_message }
    end
  end
end
