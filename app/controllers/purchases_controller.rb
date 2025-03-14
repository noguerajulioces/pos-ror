class PurchasesController < ApplicationController
  before_action :set_purchase, only: [:show, :edit, :update, :destroy]

  def index
    @purchases = Purchase.all.order(purchase_date: :desc)
  end

  def show
    @purchase_items = @purchase.purchase_items.includes(:product)
  end

  def new
    @purchase = Purchase.new
  end

  def create
    @purchase = Purchase.new(purchase_params)

    if @purchase.save
      redirect_to @purchase, notice: 'Compra creada exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @purchase.update(purchase_params)
      redirect_to @purchase, notice: 'Compra actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @purchase.destroy
    redirect_to purchases_path, notice: 'Compra eliminada exitosamente.'
  end

  private

  def set_purchase
    @purchase = Purchase.find(params[:id])
  end

  def purchase_params
    params.require(:purchase).permit(:purchase_date, :supplier_id, :total_amount)
  end
end