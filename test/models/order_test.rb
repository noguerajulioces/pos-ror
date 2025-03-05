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
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
