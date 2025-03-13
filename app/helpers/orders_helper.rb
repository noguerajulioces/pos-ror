module OrdersHelper
  def display_order_type(order_type)
    case order_type
    when "in_store"
      "En local"
    when "delivery"
      "Delivery"
    else
      order_type || "N/A"
    end
  end
end