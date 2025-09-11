# frozen_string_literal: true

module CashRegisterServices
  # Service para manejar el cierre de cajas registradoras
  # Centraliza la lógica de cierre y cálculos relacionados
  class CloseService
    attr_reader :cash_register, :user

    def initialize(cash_register, user)
      @cash_register = cash_register
      @user = user
    end

    # Cierra la caja con el monto final proporcionado
    def close!(final_amount)
      return failure_result('Caja ya está cerrada') unless cash_register.status == 'open'
      return failure_result('Solo el usuario propietario puede cerrar la caja') unless can_close?

      if cash_register.close!(final_amount)
        success_result
      else
        failure_result(cash_register.errors.full_messages.join(', '))
      end
    end

    # Calcula los totales esperados para el cierre
    def closing_calculations
      sales_total = calculate_sales_total
      expected_amount = cash_register.initial_amount + sales_total

      {
        initial_amount: cash_register.initial_amount,
        sales_total: sales_total,
        expected_amount: expected_amount,
        period: {
          start: cash_register.open_at,
          end: Time.current
        }
      }
    end

    # Verifica si la caja puede ser cerrada por el usuario actual
    def can_close?
      cash_register.user_id == user.id || user.super_user?
    end

    private

    def calculate_sales_total
      Order.where(user_id: cash_register.user_id, status: 'completed')
           .where('created_at >= ?', cash_register.open_at)
           .sum(:total_amount) || 0
    end

    def success_result
      { success: true, message: 'Caja cerrada correctamente' }
    end

    def failure_result(message)
      { success: false, message: message }
    end
  end
end
