# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  discount_percentage :decimal(5, 2)
#  discount_reason     :string
#  order_date          :datetime
#  order_type          :string
#  status              :string
#  total_amount        :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_id         :bigint
#  payment_method_id   :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_orders_on_customer_id        (customer_id)
#  index_orders_on_payment_method_id  (payment_method_id)
#  index_orders_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :payment_method
  belongs_to :customer, optional: true
  has_many :order_items, dependent: :destroy
  has_many :order_payments, dependent: :destroy

  default_scope { order(order_date: :desc) }

  # Define order statuses
  STATUSES = {
    on_hold: "on_hold",
    completed: "completed",
    cancelled: "cancelled"
  }

  # Define order types as enum
  enum :order_type, {
    in_store: "in_store",
    delivery: "delivery"
  }, default: "in_store"

  enum :status, STATUSES

  validates :order_date, :total_amount, :status, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES.values }
  validates :order_type, inclusion: { in: order_types.keys }
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def calculate_total
    subtotal = order_items.inject(0) { |sum, item| sum + item.subtotal }
    if discount_percentage.present? && discount_percentage > 0
      subtotal - calculate_discount(subtotal)
    else
      subtotal
    end
  end

  def calculate_discount(amount)
    return 0 unless discount_percentage.present? && discount_percentage > 0
    (amount * discount_percentage / 100).round(2)
  end

  def subtotal_before_discount
    order_items.inject(0) { |sum, item| sum + item.subtotal }
  end

  def discount_amount
    calculate_discount(subtotal_before_discount)
  end

  def total_paid
    order_payments.sum(:amount)
  end

  def outstanding_balance
    total_amount - total_paid
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "customer_id", "discount_percentage", "discount_reason", "id", "order_date", "order_type", "payment_method_id", "status", "total_amount", "updated_at", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "customer", "order_items", "order_payments", "payment_method", "user" ]
  end
end
