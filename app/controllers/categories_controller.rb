class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy products]
  def index
    @categories = Category.where(parent_id: nil).includes(:products, subcategories: :products).paginate(page: params[:page], per_page: 10)
  end

  def new
    @category = Category.new
    @parent_categories = Category.where(parent_id: nil)
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: 'Categoría creada con éxito.'
    else
      render :new
    end
  end

  def edit
    @parent_categories = Category.where(parent_id: nil)
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'Categoría actualizada con éxito.'
    else
      render :edit
    end
  end

  def products
    @products = @category.products.order(:name)
    parent_cats = Category.where(parent_id: nil).includes(:subcategories).order(:name)
    @categories_for_select = parent_cats.flat_map do |cat|
      subs = cat.subcategories.order(:name)
      [ [cat.name, cat.id] ] + subs.map { |s| ["  └ #{s.name}", s.id] }
    end
  end

  def subcategories_json
    category = Category.find(params[:id])
    render json: category.subcategories.order(:name).map { |s| { id: s.id, name: s.name } }
  end

  def destroy
    begin
      if @category.subcategories.any?
        redirect_to categories_path, alert: 'No se puede eliminar una categoría con subcategorías.'
      elsif @category.products.any?
        redirect_to categories_path, alert: 'No se puede eliminar una categoría con productos asociados.'
      else
        @category.destroy
        redirect_to categories_path, notice: 'Categoría eliminada con éxito.'
      end
    rescue => e
      Rails.logger.error("Error al eliminar categoría: #{e.message}")
      redirect_to categories_path, alert: "No se pudo eliminar la categoría. #{e.message}"
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :parent_id)
  end
end
