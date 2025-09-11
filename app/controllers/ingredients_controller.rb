class IngredientsController < ApplicationController
  before_action :set_ingredient, only: %i[show edit update destroy]

  def index
    @q = Ingredient.ransack(params[:q])
    @ingredients = @q.result(distinct: true).includes(:unit).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @ingredient = Ingredient.new
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)

    if @ingredient.save
      if params[:product_id].present?
        # Create recipe component for the product
        product = Product.find(params[:product_id])
        recipe_component = product.recipe_components.create!(
          ingredient: @ingredient,
          quantity: 1,
          unit_id: @ingredient.unit_id,
          waste_pct: 0
        )

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.append('recipe_components_container', partial: 'products/recipe_components/row', locals: { component: recipe_component }),
              turbo_stream.update('modal', '')
            ]
          end
          format.html { redirect_to @ingredient, notice: 'Ingrediente creado exitosamente.' }
        end
      else
        redirect_to @ingredient, notice: 'Ingrediente creado exitosamente.'
      end
    else
      if params[:product_id].present?
        @product = Product.find(params[:product_id])
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update('modal', partial: 'ingredients/form_inline', locals: { ingredient: @ingredient, product: @product })
          end
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    if @ingredient.update(ingredient_params)
      redirect_to @ingredient, notice: 'Ingrediente actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient.destroy
    redirect_to ingredients_path, notice: 'Ingrediente eliminado exitosamente.'
  end

  def search
    @product = Product.find(params[:product_id]) if params[:product_id].present?
    @ingredients = Ingredient
                   .where('name ILIKE ?', "%#{params[:q]}%")
                   .includes(:unit)
                   .limit(10)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('search_results', partial: 'ingredients/search_results', locals: { ingredients: @ingredients, query: params[:q] })
      end
      format.html do
        if params[:product_id].present?
          render :search
        else
          render partial: 'ingredients/search_results', locals: { ingredients: @ingredients, query: params[:q] }
        end
      end
    end
  end

  def modal_picker
    @product = Product.find(params[:product_id])
    render partial: 'ingredients/modal_picker', locals: { product: @product }
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end

  def ingredient_params
    params.require(:ingredient).permit(
      :name, :sku, :unit_id, :stock, :min_stock, :average_cost
    )
  end
end
