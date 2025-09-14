class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def hub; end

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

    if @product.kind == 'recipe'
      @product.skip_recipe_validation = true
    end

    ActiveRecord::Base.transaction do
      if @product.save
        StockManager.create_initial_stock(@product)
        attach_image if params[:product][:image].present?

        notice_message = if @product.kind == 'recipe'
          'Producto de receta creado exitosamente. Ahora puedes agregar ingredientes editando el producto.'
        else
          'Producto creado exitosamente.'
        end

        redirect_to @product, notice: notice_message
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    # Para productos de receta, permitir actualización sin ingredientes si se están editando datos básicos
    if @product.kind == 'recipe' && params[:allow_empty_recipe].present?
      @product.skip_recipe_validation = true
    end

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

  def search
    base_query = Product.available
                        .where(kind: [ 'simple', nil ])
                        .or(Product.available.where(kind: ''))
                        .ordered

    @products = if params[:q].present? && params[:q].strip != ''
                  base_query.where('name ILIKE ? OR sku ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
                            .limit(20)
    else
                  base_query.limit(20)
    end

    respond_to do |format|
      format.json do
        render json: @products.map { |product|
          {
            id: product.id,
            name: product.name,
            code: product.sku,
            stock: product.stock
          }
        }
      end
    end
  end

  def unit
    @product = Product.find(params[:id])
    render json: { unit_id: @product.unit_id }
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
      # Campos de restaurante
      :kind, :kitchen_station, :print_name, :menu_section, :prep_time_seconds, :sort_order,
      :is_featured, :is_vegan, :is_vegetarian, :is_gluten_free, :tax_rate_id,
      availability_channels: [],
      modifier_group_ids: [],
      variants_attributes: [ :id, :name, :sku, :price, :stock, :_destroy ]
    )
  end

  # Si se sube una imagen, la asocia al producto creando un registro en ProductImage.
  def attach_image
    @product.images.create(image: params[:product][:image])
  end
end
