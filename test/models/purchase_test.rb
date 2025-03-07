# == Schema Information
#
# Table name: purchases
#
#  id            :bigint           not null, primary key
#  purchase_date :date
#  supplier      :string
#  total_amount  :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class PurchaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
