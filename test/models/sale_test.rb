# == Schema Information
#
# Table name: sales
#
#  id             :bigint           not null, primary key
#  payment_method :string
#  status         :string
#  total_amount   :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint           not null
#
# Indexes
#
#  index_sales_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
