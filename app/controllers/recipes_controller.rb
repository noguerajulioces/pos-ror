class RecipesController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy update_status]

  def index
    @q = Product.where(kind: 'recipe').ransack(params[:q])
    @products = @q.result(distinct: true).includes(:category).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @product = Product.new(kind: 'recipe')
    @product.recipe_components.build
    @available_ingredients = Ingredient.order(:name)
  end

  def create
    @product = Product.new(recipe_params)
    @product.kind = 'recipe'
    @product.stock = 0 # Las recetas inician sin stock
    # Skip recipe validation during create so components can be processed after
    @product.skip_recipe_validation = true

    if @product.save
      create_recipe_components
      attach_image if params[:product][:image].present?
      redirect_to recipe_path(@product), notice: 'Receta creada exitosamente.'
    else
      @available_ingredients = Ingredient.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_ingredients = Ingredient.order(:name)
  end

  def update
    # Skip recipe validation during update so components can be processed after
    @product.skip_recipe_validation = true
    
    if @product.update(recipe_params)
      update_recipe_components
      attach_image if params[:product][:image].present?
      redirect_to recipe_path(@product), notice: 'Receta actualizada exitosamente.'
    else
      @available_ingredients = Ingredient.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.update(status: 'inactive')
    redirect_to recipes_path, notice: 'Receta inactivada exitosamente.'
  end

  def update_status
    case @product.status
    when 'active'
      # Activar → Inactivar (manual)
      @product.update(status: 'inactive')
      redirect_to recipes_path, notice: 'Receta inactivada exitosamente.'
    when 'inactive'
      # Inactivar → Activar (manual, pero verificar stock virtual)
      if @product.virtual_stock > 0
        @product.update(status: 'active')
        redirect_to recipes_path, notice: 'Receta activada exitosamente.'
      else
        @product.update(status: 'out_of_stock')
        redirect_to recipes_path, alert: 'Receta sin ingredientes disponibles. Estado cambiado a "Sin Stock".'
      end
    when 'out_of_stock'
      # Sin Stock → Activar (solo si hay stock virtual)
      if @product.virtual_stock > 0
        @product.update(status: 'active')
        redirect_to recipes_path, notice: 'Receta activada exitosamente.'
      else
        redirect_to recipes_path, alert: 'No se puede activar: la receta no tiene ingredientes suficientes.'
      end
    end
  end

  private

  def set_product
    @product = Product.where(kind: 'recipe').friendly.find(params[:id])
  end

  def recipe_params
    params.require(:product).permit(
      :name, :sku, :category_id, :unit_id, :price, :description,
      :kitchen_station, :print_name, :menu_section, :prep_time_seconds, :sort_order,
      :is_featured, :is_vegan, :is_vegetarian, :is_gluten_free, :tax_rate_id,
      availability_channels: [],
      modifier_group_ids: []
    )
  end

  def create_recipe_components
    return unless params[:recipe_components].present?

    recipe_components_params = params.permit(recipe_components: [ :ingredient_id, :quantity, :waste_pct ])[:recipe_components]
    return unless recipe_components_params.present?

    recipe_components_params.each do |index, component_params|
      next if component_params[:ingredient_id].blank? || component_params[:quantity].blank?

      @product.recipe_components.create!(
        ingredient_id: component_params[:ingredient_id],
        quantity: component_params[:quantity],
        waste_pct: component_params[:waste_pct] || 0,
        unit_id: Ingredient.find(component_params[:ingredient_id]).unit_id
      )
    end
  end

  def update_recipe_components
    recipe_components_params = params.permit(recipe_components: [ :id, :ingredient_id, :quantity, :waste_pct ])[:recipe_components]
    return unless recipe_components_params.present?

    # Eliminar componentes existentes que no están en los nuevos parámetros.
    # Se usa really_destroy! para hard-delete y evitar conflictos con el índice único
    # cuando acts_as_paranoid deja registros "borrados" con la misma combinación (product_id, ingredient_id).
    existing_ids = recipe_components_params.values.map { |component| component[:id] }.compact
    @product.recipe_components.where.not(id: existing_ids).each(&:really_destroy!)

    recipe_components_params.each do |index, component_params|
      next if component_params[:ingredient_id].blank? || component_params[:quantity].blank?

      ingredient = Ingredient.find(component_params[:ingredient_id])
      attrs = {
        ingredient_id: ingredient.id,
        quantity: component_params[:quantity],
        waste_pct: component_params[:waste_pct] || 0,
        unit_id: ingredient.unit_id
      }

      if component_params[:id].present?
        # Actualizar componente existente
        @product.recipe_components.find(component_params[:id]).update!(attrs)
      else
        # Si existe un registro soft-deleted con ese ingrediente, restaurarlo y actualizarlo
        # en vez de crear uno nuevo (evita UniqueViolation en el índice de la DB)
        deleted = @product.recipe_components.only_deleted.find_by(ingredient_id: ingredient.id)
        if deleted
          deleted.restore!
          deleted.update!(attrs)
        else
          @product.recipe_components.create!(attrs)
        end
      end
    end
  end

  def attach_image
    @product.images.create(image: params[:product][:image])
  end
end
