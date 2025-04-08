# == Schema Information
#
# Table name: product_images
#
#  id         :bigint           not null, primary key
#  alt_text   :string
#  position   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_product_images_on_account_id  (account_id)
#  index_product_images_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (product_id => products.id)
#
class ProductImage < ApplicationRecord
  acts_as_tenant(:account)

  belongs_to :product
  has_one_attached :image

  before_create :set_position_and_alt_text

  def image_url
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
    end
  end

  private

  def set_position_and_alt_text
    self.position = product.images.count
    self.alt_text = "#{product.name} - Imagen #{position + 1}"
  end
end
