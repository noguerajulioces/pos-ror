class StockService
  def reduce_stock(order)
    order.order_items.each do |item|
      product = Product.find(item.product_id)
      new_stock = (product.stock || 0) - item.quantity

      # Prevent negative stock (optional, remove if you want to allow negative stock)
      new_stock = 0 if new_stock < 0

      product.update!(stock: new_stock)
    end
  end
end
