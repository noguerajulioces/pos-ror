class StockManager
  def self.create_initial_stock(product)
    return unless product.stock&.positive?

    InventoryMovement.create!(
      product: product,
      movement_type: 'adjustment',
      quantity: product.stock,
      reason: 'Stock inicial',
      skip_stock_update: true
    )
  end

  def self.update_stock_from_purchase(purchase)
    new(purchase).update_stock_from_purchase
  end

  def self.revert_stock_from_purchase(purchase)
    new(purchase).revert_stock_from_purchase
  end

  def self.update_stock_from_order(order)
    new(order).update_stock_from_order
  end

  def self.revert_stock_from_order(order)
    new(order).revert_stock_from_order
  end

  def initialize(document)
    @document = document
  end

  def update_stock_from_purchase
    @document.purchase_items.each do |item|
      create_inventory_movement(item, item.quantity, 'purchase')
    end
  end

  def revert_stock_from_purchase
    @document.purchase_items.each do |item|
      create_inventory_movement(item, -item.quantity, 'adjustment')
    end
  end

  def update_stock_from_order
    @document.order_items.each do |item|
      product = item.product

      # Deducir stock del producto final
      create_inventory_movement(item, -item.quantity, 'sale')

      # Si es un producto tipo receta, deducir ingredientes
      if product.kind == 'recipe'
        deduct_recipe_ingredients(product, item.quantity)
      elsif product.kind == 'combo'
        deduct_combo_components(product, item.quantity)
      end
    end
  end

  def revert_stock_from_order
    @document.order_items.each do |item|
      create_inventory_movement(item, item.quantity, 'adjustment')
    end
  end

  private

  def create_inventory_movement(item, quantity, movement_type)
    InventoryMovement.create!(
      product: item.product,
      movement_type: movement_type,
      quantity: quantity,
      reason: movement_reason(quantity, movement_type)
    )
  end

  def deduct_recipe_ingredients(product, quantity_sold)
    product.recipe_components.includes(:ingredient).each do |component|
      needed_quantity = component.total_quantity_with_waste * quantity_sold

      if component.ingredient.deduct_stock(needed_quantity)
        # Crear movimiento de inventario para el ingrediente
        create_ingredient_movement(
          component.ingredient,
          -needed_quantity,
          'recipe_production',
          "Usado en receta: #{product.name} (#{quantity_sold} unidades)"
        )
      else
        Rails.logger.warn "No se pudo deducir stock suficiente del ingrediente #{component.ingredient.name} para #{product.name}"
      end
    end
  end

  def deduct_combo_components(product, quantity_sold)
    product.combo_items.includes(:component_product).each do |combo_item|
      component_product = combo_item.component_product
      needed_quantity = combo_item.quantity * quantity_sold

      # Crear movimiento para el componente del combo
      create_inventory_movement_for_product(
        component_product,
        -needed_quantity,
        'combo_sale',
        "Usado en combo: #{product.name} (#{quantity_sold} unidades)"
      )
    end
  end

  def create_ingredient_movement(ingredient, quantity, movement_type, reason)
    # Crear un registro de movimiento para ingredientes (si tienes una tabla similar)
    # Por ahora, solo registramos en logs
    Rails.logger.info "Ingredient Movement: #{ingredient.name} - #{quantity} #{ingredient.unit.abbreviation} - #{reason}"
  end

  def create_inventory_movement_for_product(product, quantity, movement_type, reason)
    InventoryMovement.create!(
      product: product,
      movement_type: movement_type,
      quantity: quantity,
      reason: reason
    )
  end

  def movement_reason(quantity, movement_type)
    document_type = @document.class.name.downcase
    document_id = @document.id

    case movement_type
    when 'purchase'
      "Compra ##{document_id}"
    when 'sale'
      "Venta ##{document_id}"
    when 'adjustment'
      if quantity.positive?
        "Reversión Venta ##{document_id}"
      else
        "Reversión Compra ##{document_id}"
      end
    end
  end
end
