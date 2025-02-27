class StocksController < ApplicationController
  def index
    @stocks = Product.active.paginate(page: params[:page])
  end
end
