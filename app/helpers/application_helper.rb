module ApplicationHelper
  def stock_status_class(product)
    return '' unless product.stock && product.min_stock
    product.stock <= product.min_stock ? 'bg-red-50' : ''
  end

  def low_stock?(product)
    return false unless product.stock && product.min_stock
    product.stock <= product.min_stock
  end

  def stock_text_color(product)
    low_stock?(product) ? 'text-red-900' : 'text-gray-900'
  end

  def stock_value_color(product)
    low_stock?(product) ? 'text-red-700' : 'text-gray-500'
  end
end
