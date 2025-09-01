# == Schema Information
#
# Table name: purchase_items
#
#  id               :bigint           not null, primary key
#  purchasable_type :string
#  quantity         :decimal(12, 3)
#  subtotal         :decimal(12, 2)
#  total_price      :decimal(, )
#  unit_price       :decimal(12, 2)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  purchasable_id   :bigint
#  purchase_id      :bigint           not null
#  unit_id          :bigint
#
# Indexes
#
#  index_purchase_items_on_account_id                           (account_id)
#  index_purchase_items_on_purchasable_type_and_purchasable_id  (purchasable_type,purchasable_id)
#  index_purchase_items_on_purchase_id                          (purchase_id)
#  index_purchase_items_on_unit_id                              (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (purchase_id => purchases.id)
#  fk_rails_...  (unit_id => units.id)
#
require 'test_helper'

class PurchaseItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
