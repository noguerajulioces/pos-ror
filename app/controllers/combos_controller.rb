class CombosController < ApplicationController
  before_action :set_combo, only: %i[show edit update destroy toggle_status]

  def index
    @q = combo_products.ransack(params[:q])
    @combos = @q.result(distinct: true)
                .includes(:combo_items, :category, combo_items: [ :component_product ])
                .paginate(page: params[:page], per_page: 10)

    # Calcular estadísticas
    @total_combos = combo_products.count
    @active_combos = combo_products.where(status: 'active').count
    @inactive_combos = combo_products.where(status: 'inactive').count
  end

  def show
    @combo_items = @combo.combo_items.includes(:component_product)
    @available_quantity = calculate_available_quantity(@combo)
    @sales_stats = calculate_sales_stats(@combo)
  end

  def new
    @combo = Product.new(kind: 'combo', status: 'active')
    @combo.combo_items.build
    @available_products = available_products_for_combo
  end

  def create
    @combo = Product.new(combo_params)
    @combo.kind = 'combo'
    @combo.stock = 0 # Los combos no tienen stock físico
    @combo.status = 'active' if @combo.status.blank?

    if @combo.save
      create_combo_items
      redirect_to combo_path(@combo), notice: 'Combo creado exitosamente.'
    else
      @available_products = available_products_for_combo
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_products = available_products_for_combo
  end

  def update
    if @combo.update(combo_params)
      update_combo_items
      redirect_to combo_path(@combo), notice: 'Combo actualizado exitosamente.'
    else
      @available_products = available_products_for_combo
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @combo.update(status: 'inactive')
    redirect_to combos_path, notice: 'Combo desactivado exitosamente.'
  end

  def toggle_status
    new_status = @combo.status == 'active' ? 'inactive' : 'active'
    @combo.update(status: new_status)

    status_text = new_status == 'active' ? 'activado' : 'desactivado'
    redirect_to combos_path, notice: "Combo #{status_text} exitosamente."
  end

  private

  def set_combo
    @combo = combo_products.friendly.find(params[:id])
  end

  def combo_products
    Product.where(kind: 'combo')
  end

  def combo_params
    params.require(:product).permit(
      :name, :sku, :price, :description, :category_id, :status,
      :print_name, :menu_section, :sort_order, :is_featured,
      :is_vegan, :is_vegetarian, :is_gluten_free
    )
  end

  def available_products_for_combo
    Product.where(kind: [ 'simple', 'recipe' ])
           .where(status: 'active')
           .includes(:category, :unit)
           .order(:name)
  end

  def create_combo_items
    return unless params[:combo_items].present?

    combo_items_params = params.permit(combo_items: [ :component_product_id, :quantity, :optional ])[:combo_items]
    return unless combo_items_params.present?

    combo_items_params.each do |index, item_params|
      next if item_params[:component_product_id].blank? || item_params[:quantity].blank?

      @combo.combo_items.create!(
        component_product_id: item_params[:component_product_id],
        quantity: item_params[:quantity],
        optional: item_params[:optional] == '1'
      )
    end
  end

  def update_combo_items
    combo_items_params = params.permit(combo_items: [ :id, :component_product_id, :quantity, :optional ])[:combo_items]
    return unless combo_items_params.present?

    # Eliminar items existentes que no están en los nuevos parámetros
    existing_ids = combo_items_params.values.map { |item| item[:id] }.compact
    @combo.combo_items.where.not(id: existing_ids).destroy_all

    combo_items_params.each do |index, item_params|
      next if item_params[:component_product_id].blank? || item_params[:quantity].blank?

      if item_params[:id].present?
        # Actualizar item existente
        item = @combo.combo_items.find(item_params[:id])
        item.update!(
          component_product_id: item_params[:component_product_id],
          quantity: item_params[:quantity],
          optional: item_params[:optional] == '1'
        )
      else
        # Crear nuevo item
        @combo.combo_items.create!(
          component_product_id: item_params[:component_product_id],
          quantity: item_params[:quantity],
          optional: item_params[:optional] == '1'
        )
      end
    end
  end

  def calculate_available_quantity(combo)
    return 0 unless combo.combo_items.any?

    combo.combo_items.map do |item|
      component_stock = item.component_product.virtual_stock || 0
      (component_stock / item.quantity).floor
    end.min || 0
  end

  def calculate_sales_stats(combo)
    # Estadísticas básicas de ventas usando SaleItem
    sale_items = combo.sale_items.joins(:sale)

    {
      total_sold: sale_items.sum(:quantity),
      revenue: sale_items.sum(:total),
      last_sale: sale_items.maximum(:created_at),
      sales_this_month: sale_items.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).sum(:quantity),
      revenue_this_month: sale_items.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).sum(:total)
    }
  end
end
