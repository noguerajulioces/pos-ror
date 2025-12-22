module ApplicationHelper
  def stock_status_class(product)
    return '' if product.min_stock.nil?
    product.stock <= product.min_stock ? 'bg-red-50' : ''
  end

  def low_stock?(product)
    return false if product.min_stock.nil?
    product.stock <= product.min_stock
  end

  def stock_text_class(product, low_class, normal_class)
    low_stock?(product) ? low_class : normal_class
  end
end
