class PosController < ApplicationController
  include ActionView::Helpers::NumberHelper
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
    @q = Product.ransack(name_or_description_cont: params[:query])
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
      format.json { render json: { success: true } }
    end
  end

  def process_payment
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

    if session[:cart].present?
      item = session[:cart].find { |i| i['product_id'].to_s == product_id.to_s }
      if item
        # Store the current discount type mode
        item['discount_type_mode'] = discount_type_mode

        # If switching from percentage to amount, convert the percentage to an equivalent amount
        if discount_type_mode == 'amount' && item['discount_percentage'].present?
          item_subtotal = item['price'].to_i * item['quantity'].to_i
          item['discount_amount'] = (item_subtotal * item['discount_percentage'].to_f / 100).round
        end

        # If switching from amount to percentage, convert the amount to an equivalent percentage
        if discount_type_mode == 'percentage' && item['discount_amount'].present?
          item_subtotal = item['price'].to_i * item['quantity'].to_i
          item['discount_percentage'] = [ (item['discount_amount'].to_f / item_subtotal * 100).round, 100 ].min
        end
      end
    end

    # Recalculate totals
    totals = calculate_cart_totals

    respond_to do |format|
      format.json { render json: { success: true, totals: totals } }
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
end
