# frozen_string_literal: true

module CashRegisterServices
  # Service para manejar todos los cálculos analíticos de las cajas registradoras
  # Mantiene el controlador delgado y centraliza la lógica de negocio
  #
  # Uso:
  #   analytics_service = CashRegisterServices::AnalyticsService.new(cash_register)
  #   data = analytics_service.analytics
  #
  # O para métricas específicas:
  #   analytics_service.cash_summary
  #   analytics_service.payment_breakdown
  #   analytics_service.ticket_metrics
  class AnalyticsService
    attr_reader :cash_register, :orders, :order_time_range

    def initialize(cash_register)
      @cash_register = cash_register
      @order_time_range = cash_register.open_at..(cash_register.close_at || Time.current)
      @orders = load_orders
    end

    # Método principal que devuelve todas las métricas
    def analytics
      {
        cash_summary: cash_summary,
        payment_breakdown: payment_breakdown,
        ticket_metrics: ticket_metrics,
        additional_data: {
          orders: orders,
          cash_movements: cash_movements
        }
      }
    end

    # MÉTRICA 1: Resumen de Caja
    def cash_summary
      @cash_summary ||= CashSummaryCalculator.new(cash_register, orders).calculate
    end

    # MÉTRICA 2: Ventas por Método de Pago
    def payment_breakdown
      @payment_breakdown ||= PaymentBreakdownCalculator.new(orders).calculate
    end

    # MÉTRICA 3: Ticket Promedio
    def ticket_metrics
      @ticket_metrics ||= TicketMetricsCalculator.new(orders).calculate
    end

    # Datos adicionales para "más detalles"
    def cash_movements
      @cash_movements ||= cash_register.cash_movements.order(created_at: :desc)
    end

    # Métodos de conveniencia para verificaciones rápidas
    def cash_balanced?
      cash_summary[:cuadra]
    end

    def cash_difference
      cash_summary[:diferencia]
    end

    def has_discrepancy?
      !cash_balanced? && cash_register.final_amount.present?
    end

    # Método para generar reporte resumido
    def summary_report
      {
        register_id: cash_register.id,
        user: cash_register.user.name,
        period: "#{cash_register.open_at} - #{cash_register.close_at || 'Abierta'}",
        status: cash_register.status,
        balanced: cash_balanced?,
        total_sales: cash_summary[:ingresos_ventas],
        total_tickets: ticket_metrics[:total_tickets],
        average_ticket: ticket_metrics[:ticket_promedio],
        discrepancy: cash_difference
      }
    end

    private

    # Cargar órdenes del período con las asociaciones necesarias
    def load_orders
      Order.where(
        user_id: cash_register.user_id,
        created_at: order_time_range,
        status: 'completed'
      ).includes(:customer, :order_payments, order_payments: :payment_method)
    end

    # Calculador especializado para resumen de caja
    class CashSummaryCalculator
      def initialize(cash_register, orders)
        @cash_register = cash_register
        @orders = orders
      end

      def calculate
        total_sales = @orders.sum(:total_amount) || 0
        cash_movements = @cash_register.cash_movements
        total_ingresos = cash_movements.where(movement_type: 'ingreso').sum(:amount) || 0
        total_egresos = cash_movements.where(movement_type: 'egreso').sum(:amount) || 0

        # Cálculos principales
        saldo_inicial = @cash_register.initial_amount
        saldo_esperado = saldo_inicial + total_sales + total_ingresos - total_egresos
        saldo_real = @cash_register.final_amount
        diferencia = saldo_real.present? ? (saldo_real - saldo_esperado) : nil

        {
          saldo_inicial: saldo_inicial,
          ingresos_ventas: total_sales,
          ingresos_extra: total_ingresos,
          egresos: total_egresos,
          saldo_esperado: saldo_esperado,
          saldo_real: saldo_real,
          diferencia: diferencia,
          cuadra: diferencia&.zero? || diferencia.nil?
        }
      end
    end

    # Calculador especializado para desglose de pagos
    class PaymentBreakdownCalculator
      def initialize(orders)
        @orders = orders
      end

      def calculate
        order_ids = @orders.pluck(:id)
        payments = OrderPayment.joins(:payment_method)
                              .where(order_id: order_ids, status: 'completed')
                              .group('payment_methods.name')
                              .sum(:amount)

        total_amount = payments.values.sum

        breakdown = payments.map do |payment_method_name, amount|
          percentage = total_amount > 0 ? (amount * 100.0 / total_amount).round(1) : 0
          {
            name: payment_method_name,
            amount: amount,
            percentage: percentage
          }
        end.sort_by { |item| -item[:amount] } # Ordenar por monto descendente

        {
          breakdown: breakdown,
          total: total_amount
        }
      end
    end

    # Calculador especializado para métricas de tickets
    class TicketMetricsCalculator
      def initialize(orders)
        @orders = orders
      end

      def calculate
        total_tickets = @orders.count
        total_sales = @orders.sum(:total_amount) || 0
        ticket_promedio = total_tickets > 0 ? (total_sales / total_tickets).round(0) : 0

        {
          total_tickets: total_tickets,
          total_sales: total_sales,
          ticket_promedio: ticket_promedio
        }
      end
    end
  end
end
