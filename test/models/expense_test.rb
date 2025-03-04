# == Schema Information
#
# Table name: expenses
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )
#  description       :text
#  expense_date      :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_method_id :bigint           not null
#  purchase_id       :bigint           not null
#
# Indexes
#
#  index_expenses_on_payment_method_id  (payment_method_id)
#  index_expenses_on_purchase_id        (purchase_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (purchase_id => purchases.id)
#
require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
