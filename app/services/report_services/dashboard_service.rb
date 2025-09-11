# frozen_string_literal: true

module ReportServices
  # Service para generar datos del dashboard principal
  # Agrega información de múltiples módulos para una vista general
  class DashboardService
    attr_reader :user, :date_range

    def initialize(user, date_range: Date.current.beginning_of_day..Date.current.end_of_day)
      @user = user
      @date_range = date_range
    end

    # Datos completos del dashboard
    def dashboard_data
      {
        cash_register_status: cash_register_status,
        sales_summary: sales_summary,
        alerts: system_alerts,
        quick_stats: quick_stats
      }
    end

    private

    def cash_register_status
      validation_service = CashRegisterServices::ValidationService.new(user)

      {
        has_open_register: validation_service.has_open_register?,
        current_register: validation_service.current_open_register,
        can_open_new: validation_service.can_open_new_register?,
        needs_attention: validation_service.registers_needing_attention
      }
    end

    def sales_summary
      if user.super_user?
        # Vista global para superadmin
        OrderServices::AnalyticsService.new(date_range: date_range).analytics
      else
        # Vista personal para usuario regular
        OrderServices::AnalyticsService.new(date_range: date_range, user_id: user.id).analytics
      end
    end

    def system_alerts
      alerts = []

      # Alertas de cajas
      validation_service = CashRegisterServices::ValidationService.new(user)
      needs_attention = validation_service.registers_needing_attention

      if needs_attention[:previous_day_open].any?
        alerts << {
          type: 'warning',
          message: "Hay #{needs_attention[:previous_day_open].count} cajas de días anteriores sin cerrar",
          action: 'cash_registers_path'
        }
      end

      if needs_attention[:discrepancies].any?
        alerts << {
          type: 'error',
          message: "#{needs_attention[:discrepancies].count} cajas cerradas con discrepancias",
          action: 'cash_registers_path'
        }
      end

      alerts
    end

    def quick_stats
      {
        today_sales: Order.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day, status: 'completed').sum(:total_amount),
        active_users: User.active.count,
        low_stock_products: Product.joins(:stocks).where('stocks.quantity < 10').count,
        pending_orders: Order.where(status: 'on_hold').count
      }
    end
  end
end
