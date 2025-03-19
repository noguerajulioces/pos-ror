module Products
  class StockAdjustmentsController < ApplicationController
    before_action :set_product

    def new
      @current_stock = @product.stock
    end

    def create
      result = StockAdjustmentService.new(
        product: @product,
        quantity: params[:quantity],
        reason: params[:reason],
        user: current_user
      ).call

      if result[:success]
        redirect_to @product, notice: result[:message]
      else
        redirect_to new_product_stock_adjustment_path(@product),
                    alert: result[:error]
      end
    end

    private

    def set_product
      @product = Product.friendly.find(params[:product_id])
    end
  end
end
