class SimpleProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @q = Product.where(kind: 'simple').ransack(params[:q])
    @products = @q.result(distinct: true).includes(:category).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @product = Product.new(kind: 'simple')
  end

  def create
    @product = Product.new(product_params)
    @product.kind = 'simple'

    if @product.save
      attach_image if params[:product][:image].present?
      redirect_to product_path(@product), notice: 'Producto creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      attach_image if params[:product][:image].present?
      redirect_to simple_product_path(@product), notice: 'Producto actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Producto eliminado exitosamente.'
  end

  private

  def set_product
    @product = Product.where(kind: 'simple').friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :sku, :category_id, :unit_id, :price, :stock, :min_stock, :description,
      :manual_purchase_price, :average_cost, :barcode,
      :kitchen_station, :print_name, :menu_section, :prep_time_seconds, :sort_order,
      :is_featured, :is_vegan, :is_vegetarian, :is_gluten_free, :tax_rate_id,
      availability_channels: [],
      modifier_group_ids: []
    )
  end

  def attach_image
    @product.images.create(image: params[:product][:image])
  end
end
