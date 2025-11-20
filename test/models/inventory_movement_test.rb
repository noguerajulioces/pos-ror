# == Schema Information
#
# Table name: inventory_movements
#
#  id            :bigint           not null, primary key
#  item_type     :string           not null
#  movement_type :string
#  quantity      :decimal(10, 3)
#  reason        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  item_id       :bigint           not null
#
# Indexes
#
#  index_inventory_movements_on_account_id             (account_id)
#  index_inventory_movements_on_item_id                (item_id)
#  index_inventory_movements_on_item_type_and_item_id  (item_type,item_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'test_helper'

class InventoryMovementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
