# == Schema Information
#
# Table name: sale_items
#
#  id         :bigint           not null, primary key
#  price      :decimal(, )
#  quantity   :integer
#  total      :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#  sale_id    :bigint           not null
#
# Indexes
#
#  index_sale_items_on_product_id  (product_id)
#  index_sale_items_on_sale_id     (sale_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (sale_id => sales.id)
#
class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :product
end
