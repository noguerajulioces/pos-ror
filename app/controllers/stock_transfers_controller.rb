class StockTransfersController < ApplicationController
  before_action :set_product

  def transfer_form
    @accounts = Account.where.not(id: current_user.account_id).order(:name)
  end

  # GET — devuelve los productos simples de otra sucursal en JSON
  def products_by_account
    account = Account.find(params[:account_id])
    products = ActsAsTenant.with_tenant(account) do
      Product.where(kind: 'simple').order(:name).map do |p|
        { id: p.id, name: p.name, sku: p.sku, stock: p.stock }
      end
    end
    render json: products
  end

  def create
    to_account  = Account.find(params[:to_account_id])
    to_product  = ActsAsTenant.with_tenant(to_account) do
      Product.find(params[:to_product_id])
    end

    service = StockTransferService.new(
      from_product: @product,
      to_product:   to_product,
      to_account:   to_account,
      quantity:     params[:quantity],
      reason:       params[:reason],
      user:         current_user
    )

    transfer = service.call

    if transfer
      respond_to do |format|
        format.turbo_stream do
          @product.reload
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.update("product_stock_value_#{@product.id}",
              "#{@product.stock} #{@product.unit&.abbreviation}"),
            turbo_stream.replace("stock_display",
              partial: "shared/stock_display",
              locals: { item: @product }),
            turbo_stream.append("flash_messages",
              partial: "shared/flash",
              locals: { type: "success", message: "Transferencia completada: #{transfer.quantity} #{@product.unit&.abbreviation} enviados a #{to_account.name}" })
          ]
        end
      end
    else
      @errors   = service.errors
      @accounts = Account.where.not(id: current_user.account_id).order(:name)
      render :transfer_form, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.where(kind: 'simple').friendly.find(params[:simple_product_id])
  end
end
