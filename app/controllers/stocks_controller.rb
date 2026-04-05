class StocksController < ApplicationController
  def index
    @q = Product.active.ransack(params[:q])
    base = @q.result(distinct: true)
    @total_count     = base.count
    @low_stock_count  = Product.active.where('stock IS NOT NULL AND min_stock IS NOT NULL AND stock > 0 AND stock <= min_stock').count
    @out_of_stock_count = Product.active.where(kind: 'simple').where('stock IS NULL OR stock = 0').count
    @stocks = base.includes(:category, :images).paginate(page: params[:page], per_page: 10)
  end
end
