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
#  price_base            :decimal(, )
#  sku                   :string
#  slug                  :string
#  status                :string
#  stock                 :decimal(10, 3)
#  vat_rate              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :bigint           not null
#  category_id           :bigint           not null
#  unit_id               :bigint
#
# Indexes
#
#  index_products_on_account_id   (account_id)
#  index_products_on_category_id  (category_id)
#  index_products_on_deleted_at   (deleted_at)
#  index_products_on_slug         (slug) UNIQUE
#  index_products_on_unit_id      (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (unit_id => units.id)
#
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
