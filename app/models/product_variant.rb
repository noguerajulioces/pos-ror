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
#  account_id :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_product_variants_on_account_id  (account_id)
#  index_product_variants_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (product_id => products.id)
#
class ProductVariant < ApplicationRecord
  acts_as_tenant(:account)

  include NumericFormatter
  sanitize_numeric_attributes :price
end
