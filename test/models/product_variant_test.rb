# == Schema Information
#
# Table name: product_variants
#
#  id         :bigint           not null, primary key
#  barcode    :string
#  name       :string
#  price      :decimal(10, 2)
#  sku        :string
#  stock      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_product_variants_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
require 'test_helper'

class ProductVariantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
