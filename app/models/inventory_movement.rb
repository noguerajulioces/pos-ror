# == Schema Information
#
# Table name: inventory_movements
#
#  id            :bigint           not null, primary key
#  movement_type :string
#  quantity      :integer
#  reason        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  product_id    :bigint           not null
#
# Indexes
#
#  index_inventory_movements_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class InventoryMovement < ApplicationRecord
  belongs_to :product
end
