class StocksController < ApplicationController
  def index
    @q = Product.active.ransack(params[:q])
    @stocks = @q.result(distinct: true).includes(:category, :images).paginate(page: params[:page], per_page: 10)
  end
end
