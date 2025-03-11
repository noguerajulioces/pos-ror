# app/controllers/pos_controller.rb
class PosController < ApplicationController
  include ActionView::Helpers::NumberHelper  # Add this line at the top of your controller
  layout "pos"

  # before_action :authenticate_user!
  # before_action :ensure_cash_register_open
  before_action :check_cash_register, only: [ :show ]

  def show
    # Aquí puedes cargar los datos que necesites en la vista
    # Por ejemplo, si quieres mostrar la lista de productos:
    @products = Product.all
    @categories = Category.where(parent_id: nil)
  end


  def order_type_modal
    render partial: "order_type_modal"
  end

  # Add this method to your PosController
  def customer_search_modal
    render partial: "customer_search_modal"
  end

  def update_order_type
    @order_type = params[:type]
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.update("order_type", @order_type.titleize)
      }
    end
  end

  def orders_modal
    @orders = Order.order(created_at: :desc)
    render partial: "orders_modal"
  end

  # Add this method to your PosController
  def subcategories
    category = Category.find(params[:category_id])
    subcategories = category.subcategories.order(:name)

    render json: subcategories
  end

  # Method to fetch products by subcategory
  def products_by_subcategory
    subcategory = Category.find(params[:subcategory_id])
    products = subcategory.products.order(:name)

    # Custom JSON response with first image
    products_with_images = products.map do |product|
      product_json = product.as_json(only: [ :id, :name, :price, :stock ])

      # Add first image if available
      first_image = product.product_images.first
      if first_image&.image&.attached?
        # Generate a URL for the resized image
        variant = first_image.image.variant(resize_to_fill: [ 200, 200 ]).processed
        product_json["image_url"] = Rails.application.routes.url_helpers.rails_blob_path(variant, only_path: true)
        product_json["image_alt"] = first_image.alt_text
      end

      product_json
    end

    render json: products_with_images
  end

  # Add this method to handle adding products to the order
  def add_product_to_order
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    # Initialize or get the current order from the session
    @order = current_order

    # Add the product to the order
    @order.add_product(product, quantity)

    # Return the updated order as JSON
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

  # Helper method to get or initialize the current order
  def current_order
    # If you're using a session-based approach
    if session[:order_id].present?
      Order.find_by(id: session[:order_id]) || create_new_order
    else
      create_new_order
    end
  end

  def create_new_order
    order = Order.create(status: "draft")
    session[:order_id] = order.id
    order
  end

  # Add this method to your PosController
  def add_product_to_cart
    @product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i || 1

    # Initialize the cart in the session if it doesn't exist
    session[:cart] ||= []

    # Check if the product is already in the cart
    existing_item = session[:cart].find { |item| item["product_id"] == @product.id }

    if existing_item
      existing_item["quantity"] += quantity
    else
      session[:cart] << {
        "product_id" => @product.id,
        "name" => @product.name,
        "price" => @product.price,
        "quantity" => quantity
      }
    end

    # Recalculate discount if it's a percentage
    adjust_discount_if_needed

    # Calculate new totals
    totals = calculate_cart_totals

    # Update discount label
    discount_label = session[:discount_percentage] ? "Descuento (#{session[:discount_percentage]}%)" : "Descuento"

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(
            "cart-items-body",
            partial: "cart_items",
            locals: { cart_items: session[:cart] }
          ),
          turbo_stream.update("cart-subtotal", "GS. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-iva", "GS. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-discount", "GS. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-total", "GS. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update("discount-label", discount_label)
        ]
      }
      format.json {
        render json: {
          success: true,
          cart: session[:cart],
          totals: totals,
          discount_label: discount_label
        }
      }
    end
  end

  # Add this method to clear the cart
  def clear_cart
    # Reset the cart in the session
    session[:cart] = []

    # Reset discount and discount percentage
    session[:discount] = 0
    session[:discount_percentage] = nil

    # Calculate new totals
    totals = calculate_cart_totals

    # Update discount label (will be just "Descuento" since percentage is nil)
    discount_label = "Descuento"

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(
            "cart-items-body",
            partial: "cart_items",
            locals: { cart_items: [] }
          ),
          turbo_stream.update("cart-subtotal", "GS. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-iva", "GS. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-discount", "GS. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-total", "GS. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update("discount-label", discount_label)
        ]
      }
      format.json {
        render json: {
          success: true,
          message: "Cart cleared successfully",
          totals: totals,
          discount_label: discount_label
        }
      }
    end
  end

  # Add this method to remove an item from the cart
  def remove_from_cart
    product_id = params[:product_id].to_i

    # Initialize the cart in the session if it doesn't exist
    session[:cart] ||= []

    # Remove the item from the cart
    session[:cart].reject! { |item| item["product_id"] == product_id }

    # Recalculate discount if it's a percentage or if cart is empty
    adjust_discount_if_needed

    # Calculate new totals
    totals = calculate_cart_totals

    # Update discount label
    discount_label = session[:discount_percentage] ? "Descuento (#{session[:discount_percentage]}%)" : "Descuento"

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(
            "cart-items-body",
            partial: "cart_items",
            locals: { cart_items: session[:cart] }
          ),
          turbo_stream.update("cart-subtotal", "GS. #{number_with_delimiter(totals[:subtotal].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-iva", "GS. #{number_with_delimiter(totals[:iva].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-discount", "GS. #{number_with_delimiter(totals[:discount].to_i, delimiter: '.')}"),
          turbo_stream.update("cart-total", "GS. #{number_with_delimiter(totals[:total].to_i, delimiter: '.')}"),
          turbo_stream.update("discount-label", discount_label)
        ]
      }
      format.json {
        render json: {
          success: true,
          cart: session[:cart],
          totals: totals,
          discount_label: discount_label
        }
      }
    end
  end

  # Add this method to your PosController
  def set_customer
    session[:customer_id] = params[:customer_id]
    session[:customer_name] = params[:customer_name]

    render json: { success: true }
  end

  def set_order_type
    session[:order_type] = params[:order_type]

    respond_to do |format|
      format.json { render json: { success: true, order_type: params[:order_type] } }
    end
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

  def cash_register_modal
    render partial: "cash_register_modal"
  end

  def discount_modal
    # Simple action to render the discount modal
    render partial: "discount_modal"
  end

  def apply_discount
    discount_amount = params[:discount_amount].to_f
    discount_type = params[:discount_type]

    # Get the current subtotal
    cart_totals = calculate_cart_totals
    subtotal = cart_totals[:subtotal]

    # Calculate the discount
    if discount_type == "percentage"
      # Ensure percentage is valid (0-100)
      discount_percentage = [ 0, [ discount_amount, 100 ].min ].max
      discount = subtotal * (discount_percentage / 100)
      # Store the percentage in the session
      session[:discount_percentage] = discount_percentage.to_i
      session[:discount_fixed_amount] = nil
    else
      # For fixed discount, if cart is empty, store the original amount for later use
      if subtotal == 0
        session[:discount_fixed_amount] = discount_amount
        discount = 0
      else
        # Ensure discount is not greater than subtotal
        discount = [ discount_amount, subtotal ].min
        session[:discount_fixed_amount] = discount_amount
      end
      # Clear the percentage from the session
      session[:discount_percentage] = nil
    end

    # Save the discount in the session
    session[:discount] = discount

    # Recalculate totals
    new_totals = calculate_cart_totals

    render json: {
      success: true,
      discount: discount,
      discount_percentage: session[:discount_percentage],
      formatted_discount: "GS. #{number_with_delimiter(discount.to_i, delimiter: '.')}",
      formatted_subtotal: "GS. #{number_with_delimiter(new_totals[:subtotal].to_i, delimiter: '.')}",
      formatted_total: "GS. #{number_with_delimiter(new_totals[:total].to_i, delimiter: '.')}",
      formatted_iva: "GS. #{number_with_delimiter(new_totals[:iva].to_i, delimiter: '.')}",
      discount_label: session[:discount_percentage] ? "Descuento (#{session[:discount_percentage]}%)" : "Descuento"
    }
  end

  private

  # Helper method to adjust discount based on cart changes
  def adjust_discount_if_needed
    # If cart is empty, reset discount to 0
    if session[:cart].blank?
      session[:discount] = 0
      return
    end

    # Calculate current subtotal
    subtotal = session[:cart].sum { |item| item["price"].to_f * item["quantity"].to_i }

    # If percentage discount is applied, recalculate based on new subtotal
    if session[:discount_percentage].present?
      session[:discount] = subtotal * (session[:discount_percentage].to_f / 100)
    # If fixed discount amount was stored, apply it now that we have products
    elsif session[:discount_fixed_amount].present?
      session[:discount] = [ session[:discount_fixed_amount].to_f, subtotal ].min
    else
      # For fixed discount, ensure it doesn't exceed the subtotal
      if session[:discount].to_f > subtotal
        session[:discount] = subtotal
      end
    end
  end

  def check_cash_register
    @cash_register = CashRegister.open.first
    @needs_cash_register = @cash_register.nil?
  end

  def ensure_cash_register_open
    # Verifica que haya una caja abierta
    # (asumiendo que tienes un modelo CashRegister con un scope :open)
    @cash_register = CashRegister.open.first
    unless @cash_register
      redirect_to new_cash_register_path, notice: "Por favor, abre la caja antes de continuar."
    end
  end

  def calculate_cart_totals
    cart = session[:cart] || []

    # Calculate subtotal
    subtotal = cart.sum { |item| item["price"].to_f * item["quantity"].to_i }

    # Calculate IVA (10%)
    iva = subtotal * 0.10

    # Get discount from session or default to 0
    discount = session[:discount].to_f || 0

    # Calculate total
    # total = subtotal + iva - discount
    total = subtotal - discount

    {
      subtotal: subtotal,
      iva: iva,
      discount: discount,
      total: total
    }
  end
end
