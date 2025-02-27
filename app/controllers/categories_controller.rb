class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @categories = Category.where(parent_id: nil).includes(:subcategories)
  end

  def show
  end

  def new
    @category = Category.new
    @parent_categories = Category.where(parent_id: nil)
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "Categoría creada con éxito."
    else
      render :new
    end
  end

  def edit
    @parent_categories = Category.where(parent_id: nil)
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Categoría actualizada con éxito."
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "Categoría eliminada con éxito."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :parent_id)
  end
end
