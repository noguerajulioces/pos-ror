# == Schema Information
#
# Table name: expenses
#
#  id                :bigint           not null, primary key
#  amount            :decimal(, )
#  category          :string
#  description       :text
#  expense_date      :date
#  reference_number  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint           not null
#  payment_method_id :bigint
#  purchase_id       :bigint
#
# Indexes
#
#  index_expenses_on_account_id         (account_id)
#  index_expenses_on_category           (category)
#  index_expenses_on_payment_method_id  (payment_method_id)
#  index_expenses_on_purchase_id        (purchase_id)
#  index_expenses_on_reference_number   (reference_number)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (purchase_id => purchases.id)
#
require 'test_helper'

class ExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
