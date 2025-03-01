class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.includes(:category).paginate(page: params[:page])
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      attach_image if params[:product][:image].present?
      redirect_to @product, notice: "Producto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      attach_image if params[:product][:image].present?
      redirect_to @product, notice: "Producto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Producto eliminado exitosamente."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  # Permitimos solo los atributos que corresponden al modelo Product.
  # Notar que no incluimos :image porque lo manejamos por separado.
  def product_params
    params.require(:product).permit(
      :name, :sku, :category_id, :price, :stock, :min_stock, :description, :image,
      variants_attributes: [ :id, :name, :sku, :price, :stock, :_destroy ]
    )
  end

  # Si se sube una imagen, la asocia al producto creando un registro en ProductImage.
  def attach_image
    @product.images.create(image: params[:product][:image])
  end
end
