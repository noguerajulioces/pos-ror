# == Schema Information
#
# Table name: product_images
#
#  id         :bigint           not null, primary key
#  alt_text   :string
#  position   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_product_images_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class ProductImage < ApplicationRecord
  belongs_to :product
  has_one_attached :image
end
