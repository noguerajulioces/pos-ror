class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true).includes(:category).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    ActiveRecord::Base.transaction do
      if @product.save
        StockManager.create_initial_stock(@product)
        attach_image if params[:product][:image].present?
        redirect_to @product, notice: 'Producto creado exitosamente.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      attach_image if params[:product][:image].present?
      redirect_to @product, notice: 'Producto actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.status = 'inactive'
    @product.save!
    redirect_to products_path, notice: 'Producto inactivado exitosamente.'
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  end

  # Permitimos solo los atributos que corresponden al modelo Product.
  # Notar que no incluimos :image porque lo manejamos por separado.
  def product_params
    params.require(:product).permit(
      :name, :sku, :category_id, :unit_id, :price, :stock, :min_stock, :description,
      :manual_purchase_price, :average_cost, :barcode,
      variants_attributes: [ :id, :name, :sku, :price, :stock, :_destroy ]
    )
  end

  # Si se sube una imagen, la asocia al producto creando un registro en ProductImage.
  def attach_image
    @product.images.create(image: params[:product][:image])
  end
end
