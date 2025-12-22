module ApplicationHelper
  def stock_status_class(product)
    return '' if product.min_stock.nil?
    product.stock <= product.min_stock ? 'bg-red-50' : ''
  end
end
