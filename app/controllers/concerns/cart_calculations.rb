# app/controllers/concerns/cart_calculations.rb
module CartCalculations
  extend ActiveSupport::Concern

  def calculate_cart_totals
    cart = session[:cart] || []

    # Calculate subtotal
    subtotal = cart.sum { |item| item['price'].to_f * item['quantity'].to_i }

    # Get discount from session or default to 0
    discount = session[:discount].to_f || 0

    # Calculate total
    # total = subtotal - discount
    total = subtotal - discount

    # Calculate IVA (10%)
    iva = total * 0.10

    {
      subtotal: subtotal,
      iva: iva,
      discount: discount,
      total: total
    }
  end
end
