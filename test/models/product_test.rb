# == Schema Information
#
# Table name: products
#
#  id                    :bigint           not null, primary key
#  availability_channels :string           default([]), is an Array
#  average_cost          :decimal(12, 2)
#  barcode               :string
#  deleted_at            :datetime
#  description           :text
#  is_featured           :boolean          default(FALSE)
#  is_gluten_free        :boolean          default(FALSE)
#  is_vegan              :boolean          default(FALSE)
#  is_vegetarian         :boolean          default(FALSE)
#  kind                  :string           default("simple")
#  kitchen_station       :string
#  manual_purchase_price :decimal(12, 2)
#  menu_section          :string
#  min_stock             :decimal(12, 3)
#  name                  :string
#  prep_time_seconds     :integer          default(0)
#  price                 :decimal(12, 2)
#  print_name            :string
#  sku                   :string
#  slug                  :string
#  sort_order            :integer          default(0)
#  status                :string
#  stock                 :decimal(12, 3)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :bigint           not null
#  category_id           :bigint           not null
#  tax_rate_id           :bigint
#  unit_id               :bigint
#
# Indexes
#
#  index_products_on_account_id             (account_id)
#  index_products_on_availability_channels  (availability_channels) USING gin
#  index_products_on_category_id            (category_id)
#  index_products_on_deleted_at             (deleted_at)
#  index_products_on_kind                   (kind)
#  index_products_on_kitchen_station        (kitchen_station)
#  index_products_on_menu_section           (menu_section)
#  index_products_on_slug                   (slug) UNIQUE
#  index_products_on_sort_order             (sort_order)
#  index_products_on_tax_rate_id            (tax_rate_id)
#  index_products_on_unit_id                (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (tax_rate_id => tax_rates.id)
#  fk_rails_...  (unit_id => units.id)
#
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
