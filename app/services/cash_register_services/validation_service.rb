# frozen_string_literal: true

module CashRegisterServices
  # Service para validaciones de cajas registradoras
  # Centraliza las reglas de negocio relacionadas con validaciones
  class ValidationService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Valida si el usuario puede abrir una nueva caja
    def can_open_new_register?
      result = {
        can_open: true,
        reasons: []
      }

      if has_open_register?
        result[:can_open] = false
        result[:reasons] << 'Ya tienes una caja abierta'
      end

      if has_previous_day_registers?
        result[:can_open] = false
        result[:reasons] << 'Tienes cajas de días anteriores sin cerrar'
      end

      result
    end

    # Verifica si hay cajas abiertas de días anteriores
    def has_previous_day_registers?
      ::CashRegister.from_previous_days.where(user: user).exists?
    end

    # Verifica si el usuario tiene una caja abierta actualmente
    def has_open_register?
      user.cash_registers.open.exists?
    end

    # Obtiene la caja abierta del usuario
    def current_open_register
      user.cash_registers.open.first
    end

    # Valida los permisos para acciones específicas
    def validate_permissions(action, cash_register = nil)
      case action
      when :view_details
        user.super_user?
      when :close_register
        return false unless cash_register
        cash_register.user_id == user.id || user.super_user?
      when :force_close
        user.super_user?
      else
        false
      end
    end

    # Obtiene cajas que necesitan atención
    def registers_needing_attention
      {
        previous_day_open: ::CashRegister.from_previous_days.includes(:user),
        discrepancies: registers_with_discrepancies,
        forced_closures: ::CashRegister.where(status: 'forced_closed').includes(:user)
      }
    end

    private

    def registers_with_discrepancies
      # Esta lógica podría ser más compleja dependiendo de cómo defines "discrepancias"
      ::CashRegister.where(status: 'closed')
                   .where.not(final_amount: nil)
                   .select { |register| has_discrepancy?(register) }
    end

    def has_discrepancy?(register)
      analytics = CashRegisterServices::AnalyticsService.new(register)
      analytics.has_discrepancy?
    end
  end
end
