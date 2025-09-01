class PurchasesController < ApplicationController
  before_action :set_purchase, only: %i[show edit update destroy post cancel]

  def index
    @q = Purchase.ransack(params[:q])
    @purchases = @q.result(distinct: true).includes(:supplier).ordered.paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @purchase = Purchase.new
    @purchase.purchase_items.build
  end

  def create
    @purchase = Purchase.new(purchase_params)

    if @purchase.save
      redirect_to @purchase, notice: 'Compra creada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @purchase.editable?
      redirect_to @purchase, alert: 'No se puede editar una compra ya posteada.'
      nil
    end
  end

  def update
    unless @purchase.editable?
      redirect_to @purchase, alert: 'No se puede editar una compra ya posteada.'
      return
    end

    if @purchase.update(purchase_params)
      redirect_to @purchase, notice: 'Compra actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @purchase.editable?
      redirect_to @purchase, alert: 'No se puede eliminar una compra ya posteada.'
      return
    end

    @purchase.destroy
    redirect_to purchases_path, notice: 'Compra eliminada exitosamente.'
  end

  def post
    begin
      @purchase.post!
      redirect_to @purchase, notice: 'Compra posteada exitosamente.'
    rescue StandardError => e
      redirect_to @purchase, alert: "Error al postear la compra: #{e.message}"
    end
  end

  def cancel
    begin
      @purchase.cancel!
      redirect_to @purchase, notice: 'Compra cancelada exitosamente.'
    rescue StandardError => e
      redirect_to @purchase, alert: "Error al cancelar la compra: #{e.message}"
    end
  end

  private

  def set_purchase
    @purchase = Purchase.find(params[:id])
  end

  def purchase_params
    params.require(:purchase).permit(
      :purchase_date, :supplier_id, :invoice_number, :payment_method, :notes,
      purchase_items_attributes: [
        :id, :purchasable_type, :purchasable_id, :unit_id, :quantity, :unit_price, :_destroy
      ]
    )
  end
end
