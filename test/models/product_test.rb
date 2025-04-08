# == Schema Information
#
# Table name: products
#
#  id                    :bigint           not null, primary key
#  average_cost          :decimal(, )
#  barcode               :string
#  deleted_at            :datetime
#  description           :text
#  manual_purchase_price :decimal(, )
#  min_stock             :decimal(10, 3)
#  name                  :string
#  price                 :decimal(, )
#  sku                   :string
#  slug                  :string
#  status                :string
#  stock                 :decimal(10, 3)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  category_id           :bigint           not null
#  unit_id               :bigint
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#  index_products_on_deleted_at   (deleted_at)
#  index_products_on_slug         (slug) UNIQUE
#  index_products_on_unit_id      (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (unit_id => units.id)
#
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
