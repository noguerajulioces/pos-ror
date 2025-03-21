class CurrenciesController < ApplicationController
  before_action :set_currency, only: [ :show, :edit, :update, :destroy ]

  def index
    @currencies = Currency.all
  end

  def new
    @currency = Currency.new
  end

  def create
    @currency = Currency.new(currency_params)

    if @currency.save
      redirect_to currencies_path, notice: 'Moneda creada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @currency is set by before_action
  end

  def update
    if @currency.update(currency_params)
      redirect_to currencies_path, notice: 'Moneda actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @currency.destroy
    redirect_to currencies_path, notice: 'Moneda eliminada exitosamente.'
  end

  def show; end

  private

  def set_currency
    @currency = Currency.find(params[:id])
  end

  def currency_params
    params.require(:currency).permit(:name, :code, :symbol, :exchange_rate, :flag_url, :display)
  end
end
