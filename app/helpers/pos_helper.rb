module PosHelper
  # Modifica este método en tu helper o controlador
  def calculate_cart_totals
    cart = session[:cart] || []

    # Calculate subtotal
    subtotal = cart.sum { |item| item['price'].to_f * item['quantity'].to_f }

    # Calculate item-level discounts
    item_discounts = 0
    cart.each do |item|
      item_price = item['price'].to_f
      item_quantity = item['quantity'].to_f
      item_subtotal = item_price * item_quantity
      
      if item['discount_type_mode'] == 'amount' && item['discount_amount'].present?
        # Si es descuento por monto fijo
        item_discounts += [item['discount_amount'].to_f, item_subtotal].min
      elsif item['discount_percentage'].present?
        # Si es descuento por porcentaje
        discount_percentage = [item['discount_percentage'].to_f, 100].min
        item_discounts += (item_subtotal * discount_percentage / 100)
      end
    end

    # Get global discount from session or default to 0
    global_discount = session[:discount].to_f || 0
    
    # Get global discount percentage if present
    global_discount_percentage = session[:discount_percentage].to_f || 0
    if global_discount_percentage > 0
      global_discount += (subtotal * global_discount_percentage / 100)
    end
    
    # Total discount is the sum of item-level and global discounts
    total_discount = item_discounts + global_discount

    # Calculate total
    total = subtotal - total_discount

    # Calculate IVA (10%)
    iva = total * 0.10

    {
      subtotal: subtotal,
      iva: iva,
      discount: total_discount,
      discount_percentage: global_discount_percentage,
      total: total
    }
  end
end
