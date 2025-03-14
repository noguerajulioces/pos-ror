class StockManager
  def self.create_initial_stock(product)
    return unless product.stock&.positive?

    InventoryMovement.create!(
      product: product,
      movement_type: "adjustment",
      quantity: product.stock,
      reason: "Stock inicial",
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
      create_inventory_movement(item, item.quantity, "purchase")
    end
  end

  def revert_stock_from_purchase
    @document.purchase_items.each do |item|
      create_inventory_movement(item, -item.quantity, "adjustment")
    end
  end

  def update_stock_from_order
    @document.order_items.each do |item|
      create_inventory_movement(item, -item.quantity, "sale")
    end
  end

  def revert_stock_from_order
    @document.order_items.each do |item|
      create_inventory_movement(item, item.quantity, "adjustment")
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

  def movement_reason(quantity, movement_type)
    document_type = @document.class.name.downcase
    document_id = @document.id

    case movement_type
    when "purchase"
      "Compra ##{document_id}"
    when "sale"
      "Venta ##{document_id}"
    when "adjustment"
      if quantity.positive?
        "Reversión Venta ##{document_id}"
      else
        "Reversión Compra ##{document_id}"
      end
    end
  end
end
