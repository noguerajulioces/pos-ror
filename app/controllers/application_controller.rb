class ApplicationController < ActionController::Base
  before_action :check_previous_day_cash_registers
  before_action :authenticate_user!, unless: :pages_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  set_current_tenant_through_filter
  before_action :set_current_account

  private

  def pages_controller?
    controller_name == 'pages'
  end

  def set_current_account
    ActsAsTenant.current_tenant = current_user.account if current_user
  end

  def check_previous_day_cash_registers
    # Only run this check once per session
    return if session[:cash_registers_checked]

    if CashRegister.has_previous_day_open_registers?
      # Auto-close registers from previous days
      CashRegister.auto_close_previous_day_registers

      # Optionally, show a flash message to inform the user
      flash[:notice] = 'Se han cerrado automáticamente cajas que quedaron abiertas de días anteriores.'
    end

    # Mark as checked in this session
    session[:cash_registers_checked] = true
  end
end
