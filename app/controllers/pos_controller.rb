# app/controllers/pos_controller.rb
class PosController < ApplicationController
  layout "pos"

  # before_action :authenticate_user!
  # before_action :ensure_cash_register_open

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

  private

  def ensure_cash_register_open
    # Verifica que haya una caja abierta
    # (asumiendo que tienes un modelo CashRegister con un scope :open)
    @cash_register = CashRegister.open.first
    unless @cash_register
      redirect_to new_cash_register_path, notice: "Por favor, abre la caja antes de continuar."
    end
  end
end
