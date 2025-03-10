class ProductImagesController < ApplicationController
  before_action :set_product
  before_action :set_product_image

  def destroy
    @product_image.destroy
    redirect_to product_path(@product), notice: "Imagen eliminada correctamente"
  end

  private

  def set_product
    @product = Product.friendly.find(params[:product_id])
  end

  def set_product_image
    @product_image = @product.images.find(params[:id])
  end
end
