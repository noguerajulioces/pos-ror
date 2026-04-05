class IngredientTransfersController < ApplicationController
  before_action :set_ingredient

  def transfer_form
    @accounts = Account.where.not(id: current_user.account_id).order(:name)
  end

  def ingredients_by_account
    account = Account.find(params[:account_id])
    ingredients = ActsAsTenant.with_tenant(account) do
      Ingredient.order(:name).map do |i|
        { id: i.id, name: i.name, sku: i.sku, stock: i.stock }
      end
    end
    render json: ingredients
  end

  def create
    to_account    = Account.find(params[:to_account_id])
    to_ingredient = ActsAsTenant.with_tenant(to_account) do
      Ingredient.find(params[:to_ingredient_id])
    end

    service = StockTransferService.new(
      from_product: @ingredient,
      to_product:   to_ingredient,
      to_account:   to_account,
      quantity:     params[:quantity],
      reason:       params[:reason],
      user:         current_user
    )

    transfer = service.call

    if transfer
      respond_to do |format|
        format.turbo_stream do
          @ingredient.reload
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.append("flash_messages",
              partial: "shared/flash",
              locals: {
                type: "success",
                message: "Transferencia completada: #{transfer.quantity} #{@ingredient.unit&.abbreviation} enviados a #{to_account.name}"
              })
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

  def set_ingredient
    @ingredient = Ingredient.find(params[:ingredient_id])
  end
end
