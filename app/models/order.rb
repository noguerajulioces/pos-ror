# == Schema Information
#
# Table name: orders
#
#  id                :bigint           not null, primary key
#  order_date        :datetime
#  status            :string
#  total_amount      :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_method_id :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_orders_on_payment_method_id  (payment_method_id)
#  index_orders_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :payment_method
  has_many :order_items, dependent: :destroy

  # Define order statuses
  STATUSES = {
    on_hold: "on_hold",
    completed: "completed",
    cancelled: "cancelled"
  }

  validates :order_date, :total_amount, :status, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES.values }

  def calculate_total
    order_items.inject(0) { |sum, item| sum + item.subtotal }
  end
end
