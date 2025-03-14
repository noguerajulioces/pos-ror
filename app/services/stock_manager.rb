class StockManager
  def self.update_stock_from_purchase(purchase)
    purchase.purchase_items.each do |item|
      product = item.product
      product.update!(stock: product.stock + item.quantity)
    end
  end

  def self.revert_stock_from_purchase(purchase)
    purchase.purchase_items.each do |item|
      product = item.product
      product.update!(stock: product.stock - item.quantity)
    end
  end
end
