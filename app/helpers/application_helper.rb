module ApplicationHelper
  def stock_status_class(product)
    product.stock <= product.min_stock ? 'bg-red-50' : ''
  end
end
