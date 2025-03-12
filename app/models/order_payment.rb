# == Schema Information
#
# Table name: order_payments
#
#  id           :bigint           not null, primary key
#  amount       :decimal(, )
#  payment_date :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  order_id     :bigint           not null
#
# Indexes
#
#  index_order_payments_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class OrderPayment < ApplicationRecord
  belongs_to :order

  validates :amount, numericality: { greater_than: 0 }
end
