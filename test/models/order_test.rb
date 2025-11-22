# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  delivery_amount     :decimal(12, 2)   default(0.0)
#  discount_percentage :decimal(5, 2)
#  discount_reason     :string
#  notes               :text
#  order_date          :datetime
#  order_type          :string
#  receipt_number      :string
#  status              :string
#  total_amount        :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :bigint           not null
#  customer_id         :bigint
#  delivery_user_id    :bigint
#  payment_method_id   :bigint
#  table_id            :bigint
#  user_id             :bigint           not null
#
# Indexes
#
#  index_orders_on_account_id         (account_id)
#  index_orders_on_customer_id        (customer_id)
#  index_orders_on_delivery_user_id   (delivery_user_id)
#  index_orders_on_payment_method_id  (payment_method_id)
#  index_orders_on_table_id           (table_id)
#  index_orders_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (delivery_user_id => users.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (table_id => tables.id)
#  fk_rails_...  (user_id => users.id)
#
require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "display_payment_method returns Credit when no payment method is present" do
    order = orders(:one)
    order.payment_method = nil
    assert_equal "Crédito", order.display_payment_method
  end

  test "display_payment_method returns Credit when outstanding balance is positive" do
    order = orders(:one)
    order.payment_method = payment_methods(:one)
    # Ensure there's an outstanding balance
    order.total_amount = 100
    # We need to ensure total_paid is less than 100.
    # Assuming total_paid sums order_payments.
    order.order_payments.destroy_all
    
    assert_equal "Crédito", order.display_payment_method
  end

  test "display_payment_method returns payment method name when fully paid" do
    order = orders(:one)
    payment_method = payment_methods(:one)
    order.payment_method = payment_method
    
    # Ensure it is fully paid
    order.total_amount = 10.0
    order.order_payments.destroy_all
    order.order_payments.create!(
      amount: 10.0, 
      payment_method: payment_method, 
      payment_date: Date.today, 
      account: order.account
    )
    
    assert_equal payment_method.name, order.display_payment_method
  end
end
