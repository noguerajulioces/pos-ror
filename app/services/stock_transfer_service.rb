class StockTransferService
  attr_reader :errors

  def initialize(from_product:, to_product:, to_account:, quantity:, reason:, user:)
    @from_product = from_product
    @from_account = from_product.account
    @to_product   = to_product
    @to_account   = to_account
    @quantity     = quantity.to_d
    @reason       = reason
    @user         = user
    @errors       = []
  end

  def call
    return nil unless valid?

    transfer = nil

    ApplicationRecord.transaction do
      # 1. Descuenta stock en cuenta origen
      ActsAsTenant.with_tenant(@from_account) do
        InventoryMovement.create!(
          item:          @from_product,
          movement_type: :transfer,
          quantity:      -@quantity,
          reason:        "Transferencia a #{@to_account.name}: #{@reason}",
          account:       @from_account
        )
      end

      # 2. Suma stock en cuenta destino
      ActsAsTenant.with_tenant(@to_account) do
        InventoryMovement.create!(
          item:          @to_product,
          movement_type: :transfer,
          quantity:      @quantity,
          reason:        "Transferencia desde #{@from_account.name}: #{@reason}",
          account:       @to_account
        )
      end

      # 3. Registra la transferencia global
      transfer = StockTransfer.create!(
        from_account:   @from_account,
        to_account:     @to_account,
        from_item:      @from_product,
        to_item:        @to_product,
        quantity:       @quantity,
        reason:         @reason,
        status:         :completed,
        transferred_by: @user
      )
    end

    transfer
  rescue ActiveRecord::Rollback
    nil
  end

  private

  def valid?
    if @quantity <= 0
      @errors << 'La cantidad debe ser mayor a 0'
      return false
    end

    if @from_account == @to_account
      @errors << 'La sucursal destino debe ser diferente a la actual'
      return false
    end

    if (@from_product.stock || 0) < @quantity
      @errors << "Stock insuficiente. Disponible: #{@from_product.stock} #{@from_product.unit&.abbreviation}"
      return false
    end

    if @reason.blank?
      @errors << 'La razón es obligatoria'
      return false
    end

    true
  end
end
