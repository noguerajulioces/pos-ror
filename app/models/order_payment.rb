# == Schema Information
#
# Table name: order_payments
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )
#  notes             :text
#  payment_date      :datetime
#  reference_number  :string
#  status            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint           not null
#  order_id          :bigint           not null
#  payment_method_id :bigint           not null
#
# Indexes
#
#  index_order_payments_on_account_id         (account_id)
#  index_order_payments_on_order_id           (order_id)
#  index_order_payments_on_payment_method_id  (payment_method_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#
class OrderPayment < ApplicationRecord
  acts_as_tenant(:account)

  include NumericFormatter
  belongs_to :order
  belongs_to :payment_method

  # Define enum for status
  enum :status, {
    completed: 'completed',
    pending: 'pending',
    cancelled: 'cancelled',
    refunded: 'refunded',
    failed: 'failed'
  }, default: 'completed'

  sanitize_numeric_attributes :amount

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :payment_date, presence: true
  validate :amount_cannot_exceed_outstanding_balance

  after_save :update_order_status_if_fully_paid

  private

  def amount_cannot_exceed_outstanding_balance
    return if amount.nil? || order.nil?
    # Only validate for orders with pending_payment status
    return unless order.status == 'pending_payment'
    
    # Calculate total paid excluding this payment
    current_total_paid = order.order_payments.where.not(id: id).sum(:amount)
    
    if current_total_paid + amount > order.total_amount
      remaining = order.total_amount - current_total_paid
      errors.add(:amount, "no puede ser mayor al saldo pendiente (#{remaining})")
    end
  end

  def update_order_status_if_fully_paid
    return unless order.present?
    
    if order.status == 'pending_payment' && order.outstanding_balance <= 0
      order.update(status: 'completed')
    end
  end
end
