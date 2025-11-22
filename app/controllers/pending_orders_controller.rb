class PendingOrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Order.where(status: 'pending_payment').ransack(params[:q])
    @orders = @q.result(distinct: true)
              .includes(:customer, :payment_method, :user)
              .order(order_date: :desc)
              .paginate(page: params[:page], per_page: 10)
    
    # Statistics
    @total_pending = Order.where(status: 'pending_payment').count
    @total_outstanding = Order.where(status: 'pending_payment').sum { |o| o.outstanding_balance }
    @total_paid_on_pending = Order.where(status: 'pending_payment').sum { |o| o.total_paid }
    @oldest_pending = Order.where(status: 'pending_payment').order(:order_date).first
  end
end
