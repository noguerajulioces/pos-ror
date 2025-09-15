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

      # Deducir stock según el tipo de producto
      case product.kind
      when 'simple'
        # Para productos simples, crear movimiento de inventario (actualiza el stock automáticamente)
        create_inventory_movement(item, -item.quantity, 'sale')
      when 'recipe'
        # Para recetas, crear movimiento histórico y deducir ingredientes
        create_inventory_movement(item, -item.quantity, 'sale')
        deduct_recipe_ingredients(product, item.quantity)
      when 'combo'
        # Para combos, NO crear movimiento propio, solo deducir componentes
        # El combo no tiene stock físico, solo sus componentes
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
          'sale',
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

      # Deducir stock del componente según su tipo
      case component_product.kind
      when 'simple'
        # Para componentes simples, SOLO crear InventoryMovement (actualiza stock automáticamente)
        # Verificar stock suficiente antes de crear el movimiento
        if (component_product.stock || 0) >= needed_quantity
          create_inventory_movement_for_product(
            component_product,
            -needed_quantity,
            'sale',
            "Usado en combo: #{product.name} (#{quantity_sold} unidades)"
          )
        else
          Rails.logger.warn "No se pudo deducir stock suficiente del producto #{component_product.name} para combo #{product.name}"
        end
      when 'recipe'
        # Para componentes recipe, deducir ingredientes (no crear movimiento del recipe)
        component_product.deduct_stock(needed_quantity)
      when 'combo'
        # Para componentes combo, procesar recursivamente
        component_product.deduct_stock(needed_quantity)
      end
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
