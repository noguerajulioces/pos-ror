module Orders
  class CartCalculator
    attr_reader :cart, :discount

    def initialize(cart:, discount: 0)
      @cart = cart || []
      @discount = discount
    end

    def totals
      {
        subtotal: subtotal,
        iva: iva,
        discount: discount,
        total: total
      }
    end

    private

    def subtotal
      cart.sum { |item| item["price"].to_f * item["quantity"].to_i }
    end

    def iva
      subtotal * 0.10
    end

    def total
      subtotal - discount
    end
  end
end
