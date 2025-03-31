class PosController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include CartCalculations
  layout 'pos'

  before_action :check_cash_register, only: [ :show ]

  def show
    @products = Product.all
    @categories = Category.where(parent_id: nil)
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
    products = subcategory.products.order(:name)

    products_with_images = products.map do |product|
      product_json = product.as_json(only: [ :id, :name, :price, :stock ])

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

  def create_order
    result = Orders::CreateService.new(
      cart: session[:cart],
      params: params,
      current_user: current_user,
      session: session
    ).call

    render json: result
  end

  def search_products
    @q = Product.ransack(name_or_sku_cont: params[:query])
    @products = @q.result(distinct: true).limit(30)

    render json: {
      products: @products.map do |product|
        product_json = {
          id: product.id,
          name: product.name,
          price: product.price,
          stock: product.stock || 0,
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

      PrintService.print_order(result[:order_id])

      session[:cart] = []
      session[:discount] = 0
      session[:discount_percentage] = nil
      session[:discount_reason] = nil
      session[:customer_id] = nil
      session[:customer_name] = nil

      respond_to do |format|
        format.html { redirect_to pos_path, notice: "Pago procesado correctamente. Orden ##{result[:order_id]} completada." }
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
            'cart-items-body',
            partial: 'pos/main/cart_items',
            locals: { cart_items: session[:cart] }
          ),
          turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update('discount-label', discount_label)
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
            'cart-items-body',
            partial: 'pos/main/cart_items',
            locals: { cart_items: session[:cart] }
          ),
          turbo_stream.update('cart-subtotal', "₲s. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-iva', "₲s. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-discount', "₲s. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update('cart-total', "₲s. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update('discount-label', discount_label)
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
