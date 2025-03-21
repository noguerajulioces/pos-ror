module PosHelper
  # Modifica este método en tu helper o controlador
  def calculate_cart_totals
    subtotal = 0

    if session[:cart].present?
      session[:cart].each do |item|
        subtotal += item['price'].to_i * item['quantity']
      end
    end

    # Obtener el descuento de la sesión (o 0 si no hay)
    discount = session[:discount] || 0

    # Calcular el total después del descuento
    total_after_discount = subtotal - discount

    # Calcular el IVA (asumiendo 10%)
    iva = total_after_discount * 0.1

    # Total final
    total = total_after_discount

    {
      subtotal: subtotal,
      discount: discount,
      iva: iva,
      total: total
    }
  end
end
