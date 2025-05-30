# == Schema Information
#
# Table name: inventory_movements
#
#  id            :bigint           not null, primary key
#  movement_type :string
#  quantity      :decimal(10, 3)
#  reason        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  product_id    :bigint           not null
#
# Indexes
#
#  index_inventory_movements_on_account_id  (account_id)
#  index_inventory_movements_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (product_id => products.id)
#
require 'test_helper'

class InventoryMovementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
