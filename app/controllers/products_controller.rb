class ProductsController < ApplicationController
  def new
    @product = Product.new
  end

  def index
    @products = Product.includes(:category).paginate(page: params[:page])
  end

  def show
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end
end
