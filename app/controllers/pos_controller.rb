class PosController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include CartCalculations

  layout :determine_layout

  before_action :check_cash_register, only: [ :show ], unless: -> { current_user&.has_role?(:mesero) }

  def show
    @categories = Category.where(parent_id: nil)
    @order_type = session[:order_type] || 'in_store'

    # Render different view for mobile
    if mobile_device?
      render 'show_mobile'
    end
  end

  def update_order_type
    @order_type = params[:type]
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.update('order_type', @order_type.titleize)
      }
    end
  end

  def subcategories
    category = Category.find(params[:category_id])
    subcategories = category.subcategories.order(:name)

    render json: subcategories
  end

  def products_by_subcategory
    subcategory = Category.find(params[:subcategory_id])
    products = subcategory.products
                          .includes(:product_images, recipe_components: :ingredient, combo_items: :component_product)
                          .where.not(status: 'inactive')
                          .order(:name)

    products_with_images = products.map do |product|
      product_json = product.as_json(only: [ :id, :name, :price ])
      product_json['stock'] = product.virtual_stock

      first_image = product.product_images.first
      if first_image&.image&.attached?
        variant = first_image.image.variant(resize_to_fill: [ 200, 200 ]).processed
        product_json['image_url'] = Rails.application.routes.url_helpers.rails_blob_path(variant, only_path: true)
        product_json['image_alt'] = first_image.alt_text
      end

      product_json
    end

    render json: products_with_images
  end

  def add_product_to_order
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    @order = current_order

    @order.add_product(product, quantity)

    render json: {
      items: @order.order_items.map do |item|
        {
          id: item.id,
          product_id: item.product_id,
          product_name: item.product.name,
          quantity: item.quantity,
          price: item.price,
          total: item.total
        }
      end,
      subtotal: @order.subtotal,
      total: @order.total
    }
  end

  def current_order
    if session[:order_id].present?
      Order.find_by(id: session[:order_id]) || create_new_order
    else
      create_new_order
    end
  end

  def create_new_order
    order = Order.create(status: 'draft')
    session[:order_id] = order.id
    order
  end

  def set_order_type
    session[:order_type] = params[:order_type]

    respond_to do |format|
      format.json { render json: { success: true, order_type: params[:order_type] } }
    end
  end

  def set_table
    session[:table_id] = params[:table_id].presence

    respond_to do |format|
      format.json { render json: { success: true, table_id: session[:table_id] } }
    end
  end

  def update_order_type_and_table
    @order_type = params[:order_type]
    session[:order_type] = @order_type
    
    # Solo guarda la mesa si el tipo es in_store, la limpia si es delivery
    if @order_type == "in_store"
      session[:table_id] = params[:table_id].presence
    else
      session[:table_id] = nil
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def create_order
    result = Orders::CreateService.new(
      cart: session[:cart],
      params: params,
      current_user: current_user,
      session: session
    ).call

    render json: result.slice(:success, :order_id, :error)
  end

  def print_kitchen
    order_id = session[:on_hold_order_id]
    return render json: { error: 'No hay cuenta abierta' }, status: :unprocessable_entity unless order_id

    order = Order.includes(order_items: :product).includes(:table, :customer).find_by(id: order_id)
    return render json: { error: 'Orden no encontrada' }, status: :not_found unless order

    kitchen_items = order.order_items.select { |i| i.quantity > i.kitchen_printed_quantity }
    return render json: { error: 'No hay items pendientes para cocina' }, status: :unprocessable_entity if kitchen_items.empty?

    session[:kitchen_print] = {
      order_id:      order.id,
      table_name:    order.table&.name,
      customer_name: order.customer&.full_name,
      items:         kitchen_items.map { |i| { name: i.product.name, quantity: i.quantity - i.kitchen_printed_quantity } }
    }

    kitchen_items.each { |i| i.update_column(:kitchen_printed_quantity, i.quantity) }

    render json: { success: true, kitchen_print_url: pos_kitchen_ticket_path }
  end

  def kitchen_ticket
    @kitchen_data = session.delete(:kitchen_print)
    render layout: 'kitchen_print'
  end

  def load_order_to_cart
    order = Order.where(account_id: current_user.account_id).find(params[:id])

    return render json: { success: false, error: 'La cuenta no está abierta' } unless order.on_hold?

    # Clear current cart
    session[:cart] = []

    # Load order items to cart
    order.order_items.includes(:product).each do |item|
      session[:cart] << {
        'product_id' => item.product_id,
        'name' => item.product.name,
        'quantity' => item.quantity,
        'price' => item.price.to_f,
        'image_url' => item.product.images.first.present? ? url_for(item.product.images.first.image.variant(resize_to_fill: [ 100, 100 ])) : nil
      }
    end

    # Load order metadata to session
    session[:on_hold_order_id] = order.id
    session[:customer_id] = order.customer_id
    session[:customer_name] = order.customer&.full_name
    session[:order_type] = order.order_type
    session[:table_id] = order.table_id
    session[:delivery_amount] = order.delivery_amount || 0
    session[:discount_percentage] = order.discount_percentage
    session[:discount_reason] = order.discount_reason
    session[:order_notes] = order.notes

    # Calculate discount in session
    if order.discount_percentage && order.discount_percentage > 0
      totals = calculate_cart_totals
      session[:discount] = totals[:discount]
    end

    render json: { success: true, message: 'Pedido cargado correctamente' }
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Pedido no encontrado' }
  end

  def save_order_notes
    session[:order_notes] = params[:notes]
    render json: { success: true }
  end

  def search_products
    # Get the kind filter from params, default to all products
    kind_filter = params[:kind_filter] || 'all'

    @q = Product.ransack(name_or_sku_cont: params[:query])
    @products = @q.result(distinct: true).includes(:images, recipe_components: :ingredient, combo_items: :component_product)

    # Filter by kind if specified
    if kind_filter != 'all'
      @products = @products.where(kind: kind_filter)
    end

    render json: {
      products: @products.map do |product|
        product_json = {
          id: product.id,
          name: product.name,
          price: product.price,
          stock: product.virtual_stock,
          sku: product.sku,
          description: product.description,
          image_url: product.images.first.present? ? url_for(product.images.first.image.variant(resize_to_fill: [ 100, 100 ])) : nil
        }
        product_json
      end
    }
  end

  def apply_discount
    product_id = params[:product_id]
    discount_percentage = params[:discount_percentage].to_i
    discount_type = params[:discount_type]
    discount_reason = params[:discount_reason]

    if session[:cart].present?
      session[:cart].each do |item|
        if item['product_id'].to_s == product_id.to_s
          item['discount_percentage'] = discount_percentage
          item['discount_type'] = discount_type if discount_type.present?
          item['discount_reason'] = discount_reason if discount_reason.present?
        end
      end
    end

    # Recalcular totales
    totals = calculate_cart_totals

    respond_to do |format|
      format.html { redirect_back(fallback_location: pos_path) }
      format.json {
        render json: {
          success: true,
          totals: totals
        }
      }
      # Add this to handle turbo_stream requests properly
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(
            'cart-items-body',
            partial: 'pos/main/cart_items',
            locals: { cart_items: session[:cart] }
          ),
          turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}")
        ]
      }
    end
  end

  def process_payment
    # Meseros no pueden procesar pagos
    if current_user.has_role?(:mesero)
      redirect_to pos_path, alert: 'Los meseros no pueden procesar pagos. Solo pueden abrir cuentas.'
      return
    end

    totals = calculate_cart_totals

    session[:discount] = totals[:discount]
    session[:discount_percentage] = totals[:discount_percentage]

    result = Orders::CreateService.new(
      cart: session[:cart],
      params: payment_params,
      current_user: current_user,
      session: session
    ).call

    if result[:success]
      respond_to do |format|
        format.html {
          if result[:order_id]
            order = Order.find(result[:order_id])
            message = if order.pending_payment?
              "Venta a crédito registrada. Orden ##{result[:order_id]} pendiente de pago."
            else
              "Pago procesado correctamente. Orden ##{result[:order_id]} completada."
            end
            flash[:notice] = message
          end
          flash[:print_order_id] = result[:order_id]
          flash[:show_print_popup] = true
          redirect_to pos_path
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to pos_path, alert: result[:error] || 'Error al procesar el pago' }
      end
    end
  end

  def change_discount_type
    product_id = params[:product_id]
    discount_type_mode = params[:discount_type_mode]
    updated_item = nil

    if session[:cart].present?
      item = session[:cart].find { |i| i['product_id'].to_s == product_id.to_s }
      if item
        item['discount_type_mode'] = discount_type_mode

        if discount_type_mode == 'amount' && item['discount_percentage'].present?
          item_subtotal = item['price'].to_i * item['quantity'].to_f
          item['discount_amount'] = (item_subtotal * item['discount_percentage'].to_f / 100).round
        end

        if discount_type_mode == 'percentage' && item['discount_amount'].present?
          item_subtotal = item['price'].to_i * item['quantity'].to_f
          item['discount_percentage'] = [ (item['discount_amount'].to_f / item_subtotal * 100).round, 100 ].min
        end

        updated_item = item.dup # Create a copy of the updated item
      end
    end

    totals = calculate_cart_totals
    discount_label = totals[:discount] > 0 ? "Descuento (#{totals[:discount_percentage]}%)" : 'Descuento'

    respond_to do |format|
      format.html { redirect_back(fallback_location: pos_path) }
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(
            'cart-items',
            partial: 'pos/main/cart_items'
          ),
          turbo_stream.update('cart-subtotal-mobile', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-subtotal-desktop', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva-mobile', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva-desktop', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount-mobile', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount-desktop', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total-mobile', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total-desktop', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update('discount-label-mobile', discount_label),
          turbo_stream.update('discount-label-desktop', discount_label)
        ]
      }
      format.json {
        render json: {
          success: true,
          totals: totals,
          discount_label: discount_label,
          cart_item: updated_item
        }
      }
    end
  end

  def apply_item_discount
    product_id = params[:product_id]
    discount_value = params[:discount_value].to_i
    discount_type_mode = params[:discount_type_mode] || 'percentage'

    if session[:cart].present?
      item = session[:cart].find { |i| i['product_id'].to_s == product_id.to_s }
      if item
        if discount_type_mode == 'amount'
          item['discount_type_mode'] = 'amount'
          item['discount_amount'] = discount_value
          # Calcular el porcentaje equivalente para referencia
          item_subtotal = item['price'].to_i * item['quantity'].to_f
          item['discount_percentage'] = [ (discount_value.to_f / item_subtotal * 100).round, 100 ].min if item_subtotal > 0
        else
          item['discount_type_mode'] = 'percentage'
          item['discount_percentage'] = [ discount_value, 100 ].min
          # Calcular el monto equivalente para referencia
          item_subtotal = item['price'].to_i * item['quantity'].to_f
          item['discount_amount'] = (item_subtotal * discount_value.to_f / 100).round
        end
      end
    end

    # Recalcular totales
    totals = calculate_cart_totals
    discount_label = totals[:discount] > 0 ? "Descuento (#{totals[:discount_percentage]}%)" : 'Descuento'

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(
            'cart-items',
            partial: 'pos/main/cart_items'
          ),
          turbo_stream.update('cart-subtotal-mobile', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-subtotal-desktop', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva-mobile', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva-desktop', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount-mobile', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount-desktop', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total-mobile', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total-desktop', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update('discount-label-mobile', discount_label),
          turbo_stream.update('discount-label-desktop', discount_label)
        ]
      }
      format.json {
        render json: {
          success: true,
          totals: totals,
          discount_label: discount_label
        }
      }
    end
  end

  private

  def determine_layout
    mobile_device? ? 'pos_mobile' : 'pos'
  end

  def mobile_device?
    browser = Browser.new(request.user_agent, accept_language: request.accept_language)
    browser.device.mobile? || browser.device.tablet?
  end
  
  helper_method :mobile_device?

  def check_cash_register
    @cash_register = current_user.cash_registers.open.first

    unless @cash_register
      redirect_to new_cash_register_path, alert: 'Debes abrir una caja antes de usar el POS.'
    end
  end

  def ensure_cash_register_open
    @cash_register = CashRegister.open.first
    unless @cash_register
      redirect_to new_cash_register_path, notice: 'Por favor, abre la caja antes de continuar.'
    end
  end

  def payment_params
    params.permit(:payment_method_id, :status, :customer_id, :order_type, :amount_received, :change_amount)
  end

  def update_quantity
    product_id = params[:product_id]
    quantity = params[:quantity].to_i

    if session[:cart].present?
      item = session[:cart].find { |i| i['product_id'].to_s == product_id.to_s }
      if item
        # Guardar los valores de descuento actuales
        discount_percentage = item['discount_percentage']
        discount_amount = item['discount_amount']
        discount_type_mode = item['discount_type_mode']
        discount_reason = item['discount_reason']

        # Actualizar la cantidad
        item['quantity'] = quantity

        # Restaurar los valores de descuento
        item['discount_percentage'] = discount_percentage
        item['discount_amount'] = discount_amount
        item['discount_type_mode'] = discount_type_mode
        item['discount_reason'] = discount_reason
      end
    end

    # Recalcular totales
    totals = calculate_cart_totals

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}")
        ]
      }
    end
  end
end
