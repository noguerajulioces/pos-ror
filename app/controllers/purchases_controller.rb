class PurchasesController < ApplicationController
  before_action :set_purchase, only: [ :show, :edit, :update, :destroy ]

  def index
    @purchases = Purchase.all.order(purchase_date: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show
    @purchase_items = @purchase.purchase_items.includes(:product)
  end

  def new
    @purchase = Purchase.new
  end

  def create
    ActiveRecord::Base.transaction do
      @purchase = Purchase.new(purchase_params)
      if @purchase.save
        StockManager.update_stock_from_purchase(@purchase)
        redirect_to @purchase, notice: "Compra creada exitosamente."
      else
        render :new
      end
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    @purchase = Purchase.new(purchase_params)
    flash.now[:alert] = "No se pudo crear la compra: #{e.message}"
    render :new
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      if @purchase.update(purchase_params)
        StockManager.update_stock_from_purchase(@purchase)
        redirect_to @purchase, notice: "Compra actualizada exitosamente."
      else
        render :edit
      end
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    redirect_to edit_purchase_path(@purchase), alert: "No se pudo actualizar la compra: #{e.message}"
  end

  def destroy
    ActiveRecord::Base.transaction do
      StockManager.revert_stock_from_purchase(@purchase)
      @purchase.destroy!
    end
    redirect_to purchases_path, notice: "Compra eliminada exitosamente."
  rescue ActiveRecord::RecordInvalid, StandardError => e
    redirect_to purchases_path, alert: "No se pudo eliminar la compra: #{e.message}"
  end

  private

  def set_purchase
    @purchase = Purchase.find(params[:id])
  end

  def purchase_params
    params.require(:purchase).permit(
      :purchase_date,
      :supplier_id,
      :total_amount,
      purchase_items_attributes: [ :id, :product_id, :quantity, :unit_price, :total_price, :_destroy ]
    )
  end
end
