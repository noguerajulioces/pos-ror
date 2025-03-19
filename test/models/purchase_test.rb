# == Schema Information
#
# Table name: purchases
#
#  id            :bigint           not null, primary key
#  purchase_date :date
#  total_amount  :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  supplier_id   :bigint
#
# Indexes
#
#  index_purchases_on_supplier_id  (supplier_id)
#
# Foreign Keys
#
#  fk_rails_...  (supplier_id => suppliers.id)
#
require "test_helper"

class PurchaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
