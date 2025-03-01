# == Schema Information
#
# Table name: products
#
#  id           :bigint           not null, primary key
#  average_cost :decimal(, )
#  barcode      :string
#  description  :text
#  min_stock    :integer
#  name         :string
#  price        :decimal(, )
#  sku          :string
#  slug         :string
#  status       :string
#  stock        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  category_id  :bigint           not null
#  unit_id      :bigint           not null
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#  index_products_on_slug         (slug) UNIQUE
#  index_products_on_unit_id      (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (unit_id => units.id)
#
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
