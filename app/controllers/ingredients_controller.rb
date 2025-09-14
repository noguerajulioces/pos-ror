class IngredientsController < ApplicationController
  before_action :set_ingredient, only: %i[show edit update destroy]

  def check_name_uniqueness
    name = params[:name]&.strip
    current_id = params[:current_id]

    if name.blank?
      render json: { exists: false }
      return
    end

    query = Ingredient.where('LOWER(name) = ?', name.downcase)
    query = query.where.not(id: current_id) if current_id.present?

    render json: { exists: query.exists? }
  end

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

    base_query = Ingredient.includes(:unit).ordered

    @ingredients = if params[:q].present? && params[:q].strip != ''
                     base_query.where('name ILIKE ? OR sku ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
                               .limit(20)
    else
                     base_query.limit(20)
    end

    respond_to do |format|
      format.json do
        render json: @ingredients.map { |ingredient|
          {
            id: ingredient.id,
            name: ingredient.name,
            code: ingredient.sku,
            stock: ingredient.stock
          }
        }
      end
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

  def unit
    @ingredient = Ingredient.find(params[:id])
    render json: { unit_id: @ingredient.unit_id }
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
