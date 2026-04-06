class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update update_category]

  def hub; end

  def show
  end

  def edit
    # Redirect to the appropriate controller based on product kind
    case @product.kind
    when 'simple'
      redirect_to edit_simple_product_path(@product)
    when 'recipe'
      redirect_to edit_recipe_path(@product)
    when 'combo'
      redirect_to edit_combo_path(@product)
    else
      # For products without a specific kind, redirect to hub
      redirect_to hub_products_path, alert: 'Este producto no puede ser editado desde aquí. Use los controladores específicos.'
    end
  end

  def update
    # Esta acción no debería ser llamada directamente ya que cada tipo de producto
    # tiene su propio controlador. Pero la mantenemos por si acaso hay algún formulario
    # que la use directamente.
    
    # Para productos de receta, permitir actualización sin ingredientes si se están editando datos básicos
    if @product.kind == 'recipe' && params[:allow_empty_recipe].present?
      @product.skip_recipe_validation = true
    end

    if @product.update(product_params)
      attach_image if params[:product][:image].present?
      
      # Redirect to the appropriate show page based on product kind
      case @product.kind
      when 'simple'
        redirect_to simple_product_path(@product), notice: 'Producto actualizado exitosamente.'
      when 'recipe'
        redirect_to recipe_path(@product), notice: 'Receta actualizada exitosamente.'
      when 'combo'
        redirect_to combo_path(@product), notice: 'Combo actualizado exitosamente.'
      else
        redirect_to @product, notice: 'Producto actualizado exitosamente.'
      end
    else
      # Si falla, redirigir al edit correspondiente
      case @product.kind
      when 'simple'
        redirect_to edit_simple_product_path(@product), alert: 'Error al actualizar el producto.'
      when 'recipe'
        redirect_to edit_recipe_path(@product), alert: 'Error al actualizar la receta.'
      when 'combo'
        redirect_to edit_combo_path(@product), alert: 'Error al actualizar el combo.'
      else
        redirect_to hub_products_path, alert: 'Error al actualizar el producto.'
      end
    end
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
            stock: product.virtual_stock
          }
        }
      end
    end
  end

  def update_category
    old_category_id = @product.category_id
    @product.skip_recipe_validation = true
    if @product.update(category_id: params[:category_id])
      old_category = Category.find(old_category_id)
      new_category = Category.find(params[:category_id])

      streams = [ turbo_stream.remove("category_product_#{@product.id}") ]

      # Si la categoría origen es subcategoría, re-renderizar el chip completo
      # (para que el color ámbar/verde se actualice). Si es padre, solo el badge.
      if old_category.parent_id.present?
        streams << turbo_stream.replace(ActionView::RecordIdentifier.dom_id(old_category),
          partial: "subcategories/subcategory", locals: { subcategory: old_category })
      else
        streams << turbo_stream.replace("product_count_badge_#{old_category_id}",
          partial: "categories/product_count_badge", locals: { category: old_category, show_zero_label: true })
      end

      if new_category.parent_id.present?
        streams << turbo_stream.replace(ActionView::RecordIdentifier.dom_id(new_category),
          partial: "subcategories/subcategory", locals: { subcategory: new_category })
      else
        streams << turbo_stream.replace("product_count_badge_#{params[:category_id]}",
          partial: "categories/product_count_badge", locals: { category: new_category, show_zero_label: true })
      end

      respond_to do |format|
        format.turbo_stream { render turbo_stream: streams }
        format.html { redirect_back fallback_location: categories_path, notice: 'Categoría actualizada.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_back fallback_location: categories_path, alert: 'Error al actualizar.' }
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
