module Products
  class StockAdjustmentService
    attr_reader :product, :quantity, :reason, :user

    def initialize(product:, quantity:, reason:, user:)
      @product = product
      @quantity = quantity.to_i
      @reason = reason
      @user = user
    end

    def call
      return failure_response('Cantidad inválida') if quantity.zero?
      return failure_response('Razón requerida') if reason.blank?

      ActiveRecord::Base.transaction do
        create_inventory_movement
        success_response
      end
    rescue => e
      failure_response(e.message)
    end

    private

    def create_inventory_movement
      InventoryMovement.create!(
        product: product,
        movement_type: 'adjustment',
        quantity: quantity,
        reason: "Ajuste manual de (#{user.name}): #{reason}"
      )
    end

    def success_response
      { success: true, message: 'Stock ajustado correctamente' }
    end

    def failure_response(error)
      { success: false, error: error }
    end
  end
end
