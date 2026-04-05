class SimpleProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy update_status adjust_stock_form adjust_stock]

  def index
    @q = Product.where(kind: 'simple').ransack(params[:q])
    @products = @q.result(distinct: true).includes(:category).paginate(page: params[:page], per_page: 10)
  end

  def show
    @inventory_movements = @product.inventory_movements
                                   .order(created_at: :desc)
                                   .paginate(page: params[:page], per_page: 10)
  end

  def new
    @product = Product.new(kind: 'simple')
  end

  def create
    @product = Product.new(product_params)
    @product.kind = 'simple'

    if @product.save
      attach_image if params[:product][:image].present?
      redirect_to simple_product_path(@product), notice: 'Producto creado exitosamente.'
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
    redirect_to simple_products_path, notice: 'Producto eliminado exitosamente.'
  end

  def update_status
    case @product.status
    when 'active'
      # Activar → Inactivar (manual)
      @product.update(status: 'inactive')
      redirect_to simple_products_path, notice: 'Producto inactivado exitosamente.'
    when 'inactive'
      # Inactivar → Activar (manual, pero verificar stock)
      if @product.stock > 0
        @product.update(status: 'active')
        redirect_to simple_products_path, notice: 'Producto activado exitosamente.'
      else
        @product.update(status: 'out_of_stock')
        redirect_to simple_products_path, alert: 'Producto sin stock. Estado cambiado a "Sin Stock".'
      end
    when 'out_of_stock'
      # Sin Stock → Activar (solo si hay stock)
      if @product.stock > 0
        @product.update(status: 'active')
        redirect_to simple_products_path, notice: 'Producto activado exitosamente.'
      else
        redirect_to simple_products_path, alert: 'No se puede activar: el producto no tiene stock disponible.'
      end
    end
  end

  def adjust_stock_form
    # Renderiza el modal con el formulario
    render :adjust_stock_form
  end

  def adjust_stock
    service = StockAdjustmentService.new(
      item: @product,
      adjustment_type: params[:adjustment_type],
      quantity: params[:quantity],
      reason: params[:reason]
    )

    movement = service.call
    
    if movement
      respond_to do |format|
        format.turbo_stream do
          @product.reload
          render turbo_stream: [
            # Cerrar modal
            turbo_stream.update("modal", ""),

            # Actualizar stock actual (show page)
            turbo_stream.replace("stock_display",
              partial: "shared/stock_display",
              locals: { item: @product }),

            # Actualizar stock en index (stocks y simple_products)
            turbo_stream.update("product_stock_value_#{@product.id}",
              "#{@product.stock} #{@product.unit&.abbreviation}"),

            # Agregar nueva fila a la tabla (al inicio)
            turbo_stream.prepend("inventory_movements_table",
              partial: "inventory_movements/row",
              locals: { movement: movement, item: @product }),

            # Mostrar toast de éxito
            turbo_stream.append("flash_messages",
              partial: "shared/flash",
              locals: { type: "success", message: "Stock actualizado correctamente" })
          ]
        end
      end
    else
      @errors = service.errors
      render :adjust_stock_form, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.where(kind: 'simple').friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :sku, :category_id, :unit_id, :price, :stock, :min_stock, :description,
      :manual_purchase_price, :average_cost, :barcode, :status,
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
