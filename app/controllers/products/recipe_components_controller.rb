class Products::RecipeComponentsController < ApplicationController
  before_action :set_product
  before_action :set_recipe_component, only: [ :destroy ]

  def create
    success_components = []
    error_messages = []

    if params[:recipe_components].present?
      # Crear múltiples componentes
      params[:recipe_components].each do |ingredient_id, component_params|
        component = @product.recipe_components.build(
          ingredient_id: ingredient_id,
          quantity: component_params[:quantity],
          unit_id: component_params[:unit_id].presence || Ingredient.find(ingredient_id).unit_id,
          waste_pct: component_params[:waste_pct] || 0
        )

        if component.save
          success_components << component
        else
          error_messages << "#{component.ingredient.name}: #{component.errors.full_messages.join(', ')}"
        end
      end
    else
      # Crear un solo componente (compatibilidad con versión anterior)
      component = @product.recipe_components.build(recipe_component_params)
      if component.save
        success_components << component
      else
        error_messages << component.errors.full_messages.join(', ')
      end
    end

    respond_to do |format|
      if success_components.any?
        format.turbo_stream do
          streams = success_components.map do |component|
            turbo_stream.append('recipe_components_container',
                              partial: 'products/recipe_components/row',
                              locals: { component: component })
          end
          streams << turbo_stream.update('modal', '')
          render turbo_stream: streams
        end
        format.html { redirect_to @product, notice: "#{success_components.count} ingrediente(s) agregado(s) exitosamente." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('modal',
                                                 partial: 'ingredients/modal_picker',
                                                 locals: { product: @product, error: error_messages.join('; ') })
        end
        format.html { redirect_to @product, alert: "Error: #{error_messages.join('; ')}" }
      end
    end
  end

  def destroy
    @recipe_component.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@recipe_component)
      end
      format.html { redirect_to @product, notice: 'Componente eliminado exitosamente.' }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_recipe_component
    @recipe_component = @product.recipe_components.find(params[:id])
  end

  def recipe_component_params
    params.require(:recipe_component).permit(:ingredient_id, :quantity, :unit_id, :waste_pct)
  end
end
