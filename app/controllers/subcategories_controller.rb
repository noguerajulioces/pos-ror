class SubcategoriesController < ApplicationController
  before_action :set_category

  def new
    @subcategory = @category.subcategories.new
  end

  def create
    @subcategory = @category.subcategories.new(subcategory_params)
    if @subcategory.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to categories_path, notice: "Subcategoría creada exitosamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:category_id])
  end

  def subcategory_params
    params.permit(:name)
  end
end
