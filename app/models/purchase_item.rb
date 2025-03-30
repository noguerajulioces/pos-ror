# == Schema Information
#
# Table name: purchase_items
#
#  id          :bigint           not null, primary key
#  quantity    :integer
#  total_price :decimal(, )
#  unit_price  :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  product_id  :bigint           not null
#  purchase_id :bigint           not null
#
# Indexes
#
#  index_purchase_items_on_product_id   (product_id)
#  index_purchase_items_on_purchase_id  (purchase_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (purchase_id => purchases.id)
#
class PurchaseItem < ApplicationRecord
  include NumericFormatter

  sanitize_numeric_attributes :total_price, :unit_price

  belongs_to :product
  belongs_to :purchase

  after_create :update_product_average_cost

  private

  def update_product_average_cost
    product.update_average_cost(unit_price, quantity)
  end
end
