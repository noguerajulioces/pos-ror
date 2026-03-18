module Orders
  class CartCalculator
    attr_reader :cart, :global_discount, :global_discount_percentage

    def initialize(cart:, global_discount: 0, global_discount_percentage: 0)
      @cart = cart || []
      @global_discount = global_discount.to_f
      @global_discount_percentage = global_discount_percentage.to_f
    end

    def totals
      {
        subtotal: subtotal,
        iva: iva,
        discount: total_discount,
        total: total
      }
    end

    private

    def subtotal
      cart.sum { |item| item['price'].to_f * item['quantity'].to_f }
    end

    def item_discounts
      total_item_discount = 0
      cart.each do |item|
        item_price = item['price'].to_f
        item_quantity = item['quantity'].to_f
        item_subtotal = item_price * item_quantity

        if item['discount_type_mode'] == 'amount' && item['discount_amount'].present?
          total_item_discount += [ item['discount_amount'].to_f, item_subtotal ].min
        elsif item['discount_percentage'].present?
          percentage = [ item['discount_percentage'].to_f, 100 ].min
          total_item_discount += (item_subtotal * percentage / 100)
        end
      end
      total_item_discount
    end

    def calculated_global_discount
      amount = global_discount
      if global_discount_percentage > 0
        amount += (subtotal * global_discount_percentage / 100)
      end
      amount
    end

    def total_discount
      item_discounts + calculated_global_discount
    end

    def iva
      total * 0.10
    end

    def total
      subtotal - total_discount
    end
  end
end
