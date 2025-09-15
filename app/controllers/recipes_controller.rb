class RecipesController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

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
    @product.destroy
    redirect_to recipes_path, notice: 'Receta eliminada exitosamente.'
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

    # Eliminar componentes existentes que no están en los nuevos parámetros
    existing_ids = recipe_components_params.values.map { |component| component[:id] }.compact
    @product.recipe_components.where.not(id: existing_ids).destroy_all

    recipe_components_params.each do |index, component_params|
      next if component_params[:ingredient_id].blank? || component_params[:quantity].blank?

      if component_params[:id].present?
        # Actualizar componente existente
        component = @product.recipe_components.find(component_params[:id])
        component.update!(
          ingredient_id: component_params[:ingredient_id],
          quantity: component_params[:quantity],
          waste_pct: component_params[:waste_pct] || 0,
          unit_id: Ingredient.find(component_params[:ingredient_id]).unit_id
        )
      else
        # Crear nuevo componente
        @product.recipe_components.create!(
          ingredient_id: component_params[:ingredient_id],
          quantity: component_params[:quantity],
          waste_pct: component_params[:waste_pct] || 0,
          unit_id: Ingredient.find(component_params[:ingredient_id]).unit_id
        )
      end
    end
  end

  def attach_image
    @product.images.create(image: params[:product][:image])
  end
end
