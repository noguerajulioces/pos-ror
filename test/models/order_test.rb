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
require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
