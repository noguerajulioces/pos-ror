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
class Product < ApplicationRecord
  include NumericFormatter
  extend FriendlyId
  friendly_id :name, use: :slugged

  sanitize_numeric_attributes :price

  belongs_to :category
  belongs_to :unit
  has_many :sale_items
  has_many :inventory_movements, dependent: :destroy
  has_many :variants, class_name: "ProductVariant", dependent: :destroy
  has_many :images, class_name: "ProductImage", dependent: :destroy
  has_many :purchase_items
  has_many :purchases, through: :purchase_items
  has_many :product_images, dependent: :destroy

  enum :status, { active: "active", inactive: "inactive", out_of_stock: "out_of_stock" }

  validates :name, :price, :sku, presence: true
  validates :sku, uniqueness: true

  before_create :generate_barcode, if: -> { barcode.blank? }
  before_save :update_stock_status

  scope :available, -> { where(status: "active") }
  scope :in_stock, -> { where(stock: 0..) }

  def update_average_cost(new_unit_price, new_quantity)
    total_cost = (average_cost * stock) + (new_unit_price * new_quantity)
    new_stock = stock + new_quantity
    self.average_cost = total_cost / new_stock
    save
  end

  private

  def generate_barcode
    self.barcode = "PROD-#{SecureRandom.hex(6).upcase}"
  end

  def update_stock_status
    self.status = stock <= 0 ? "out_of_stock" : "active"
  end
end
