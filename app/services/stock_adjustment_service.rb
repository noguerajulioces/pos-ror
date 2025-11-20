class StockAdjustmentService
  attr_reader :item, :adjustment_type, :quantity, :reason, :errors

  def initialize(item:, adjustment_type:, quantity:, reason:)
    @item = item # Product o Ingredient
    @adjustment_type = adjustment_type # 'add' o 'remove'
    @quantity = quantity.to_f
    @reason = reason
    @errors = []
  end

  def call
    validate!
    return false if errors.any?

    create_movement!
  end

  def calculated_quantity
    adjustment_type == 'add' ? quantity : -quantity
  end

  def final_stock
    (item.stock || 0) + calculated_quantity
  end

  private

  def validate!
    if quantity <= 0
      errors << "La cantidad debe ser mayor a cero"
    end

    if adjustment_type == 'remove' && calculated_quantity.abs > (item.stock || 0)
      errors << "No hay suficiente stock. Stock actual: #{item.stock}"
    end

    if reason.blank?
      errors << "Debe proporcionar una razón para el ajuste"
    end
  end

  def create_movement!
    movement = item.inventory_movements.build(
      movement_type: 'adjustment',
      quantity: calculated_quantity,
      reason: reason
    )

    if movement.save
      movement
    else
      @errors = movement.errors.full_messages
      false
    end
  end
end
