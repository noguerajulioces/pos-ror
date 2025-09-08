class Products::RecipeComponentsController < ApplicationController
  before_action :set_product
  before_action :set_recipe_component, only: [ :destroy ]

    def create
    @recipe_component = @product.recipe_components.build(recipe_component_params)

    if @recipe_component.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append('recipe_components_container', partial: 'products/recipe_components/row', locals: { component: @recipe_component }),
            turbo_stream.update('modal', '')
          ]
        end
        format.html { redirect_to @product, notice: 'Componente agregado exitosamente.' }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('modal', partial: 'ingredients/modal_picker', locals: { product: @product, error: @recipe_component.errors.full_messages.join(', ') })
        end
        format.html { redirect_to @product, alert: 'Error al agregar componente.' }
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
