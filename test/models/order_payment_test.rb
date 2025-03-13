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
#  order_id          :bigint           not null
#  payment_method_id :bigint           not null
#
# Indexes
#
#  index_order_payments_on_order_id           (order_id)
#  index_order_payments_on_payment_method_id  (payment_method_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#
require "test_helper"

class OrderPaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
