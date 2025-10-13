class DeliveryController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_delivery_access!

  def index
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current

    if current_user.has_role?(:superadmin)
      @orders = Order.where.not(delivery_user_id: nil)

      if params[:delivery_user_id].present?
        @orders = @orders.where(delivery_user_id: params[:delivery_user_id])
      end

      @orders = @orders.where(order_date: @start_date.beginning_of_day..@end_date.end_of_day)

      @orders = @orders.includes(:customer, :payment_method, :delivery_user)
                      .order(order_date: :desc)

      @delivery_users = User.joins(:roles)
                           .where(roles: { name: 'Delivery' })
                           .where(account_id: current_user.account_id)
                           .active
                           .order(:name)
    else
      @orders = Order.where(delivery_user: current_user)
                    .where(order_date: @start_date.beginning_of_day..@end_date.end_of_day)
                    .includes(:customer, :payment_method, :delivery_user)
                    .order(order_date: :desc)
    end
  end

  private

  def ensure_delivery_access!
    unless current_user.has_role?('Delivery') || current_user.has_role?(:superadmin)
      redirect_to root_path, alert: 'No tienes permisos para acceder a esta sección'
    end
  end
end
