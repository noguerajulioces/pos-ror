# frozen_string_literal: true

module OrderServices
  # Service para análisis de órdenes
  # Maneja métricas y reportes relacionados con las ventas
  class AnalyticsService
    attr_reader :date_range, :user_id

    def initialize(date_range: Date.current.beginning_of_day..Date.current.end_of_day, user_id: nil)
      @date_range = date_range
      @user_id = user_id
    end

    # Métricas principales de órdenes
    def analytics
      {
        summary: order_summary,
        top_products: top_selling_products,
        hourly_distribution: hourly_sales_distribution,
        payment_methods: payment_method_breakdown
      }
    end

    private

    def base_query
      query = Order.where(created_at: date_range, status: 'completed')
      query = query.where(user_id: user_id) if user_id
      query
    end

    def order_summary
      orders = base_query

      {
        total_orders: orders.count,
        total_revenue: orders.sum(:total_amount),
        average_order_value: orders.count > 0 ? (orders.sum(:total_amount) / orders.count).round(0) : 0,
        total_items: orders.joins(:order_items).sum('order_items.quantity')
      }
    end

    def top_selling_products(limit: 10)
      OrderItem.joins(:order, :product)
               .where(orders: { created_at: date_range, status: 'completed' })
               .group('products.name')
               .sum(:quantity)
               .sort_by { |_, qty| -qty }
               .first(limit)
               .map { |name, qty| { product: name, quantity: qty } }
    end

    def hourly_sales_distribution
      base_query.group('EXTRACT(hour FROM created_at)')
                .sum(:total_amount)
                .transform_keys(&:to_i)
                .sort
                .to_h
    end

    def payment_method_breakdown
      base_query.joins(:payment_method)
                .group('payment_methods.name')
                .sum(:total_amount)
    end
  end
end
