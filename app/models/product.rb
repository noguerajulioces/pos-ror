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
class Product < ApplicationRecord
  acts_as_tenant(:account)

  acts_as_paranoid
  include NumericFormatter
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Add manual_purchase_price to sanitized attributes
  sanitize_numeric_attributes :price, :manual_purchase_price

  belongs_to :category
  belongs_to :unit
  has_many :sale_items
  has_many :inventory_movements, dependent: :destroy
  has_many :variants, class_name: 'ProductVariant', dependent: :destroy
  has_many :images, class_name: 'ProductImage', dependent: :destroy
  has_many :purchase_items
  has_many :purchases, through: :purchase_items
  has_many :product_images, dependent: :destroy

  enum :status, { active: 'active', inactive: 'inactive', out_of_stock: 'out_of_stock' }

  validates :name, :price, :sku, presence: true
  validates :sku, uniqueness: true

  before_create :generate_barcode, if: -> { barcode.blank? }
  before_save :update_stock_status

  scope :available, -> { where(status: 'active') }
  scope :in_stock, -> { where(stock: 0..) }

  def update_average_cost(new_unit_price, new_quantity)
    total_cost = (average_cost || 0 * stock) + (new_unit_price * new_quantity)
    new_stock = stock + new_quantity
    self.average_cost = total_cost / new_stock
    save
  end

  def profit_margin_percentage
    return 0 if current_purchase_price.zero?
    ((price - current_purchase_price) / current_purchase_price * 100).round(2)
  end

  def profit_per_unit
    price - current_purchase_price
  end

  def current_purchase_price
    manual_purchase_price.presence || average_cost || 0
  end

  # Calculate the weighted average purchase price based on purchase history
  def average_purchase_price
    items = purchase_items

    if items.any?
      total_quantity = items.sum(:quantity)
      total_cost = items.sum('purchase_items.quantity * purchase_items.unit_price')

      total_quantity.positive? ? (total_cost / total_quantity) : 0
    else
      current_purchase_price || 0
    end
  end

  # Get purchase items ordered by purchase date
  def purchase_items_by_date(limit = 10)
    purchase_items.joins(:purchase)
                 .select('purchase_items.*, purchases.created_at as purchase_date')
                 .order('purchases.created_at DESC')
                 .limit(limit)
  end

  private

  def generate_barcode
    self.barcode = "PROD-#{SecureRandom.hex(6).upcase}"
  end

  def update_stock_status
    self.status = stock <= 0 ? 'out_of_stock' : 'active'
  end

  def self.ransackable_attributes(auth_object = nil)
    [ 'average_cost', 'barcode', 'category_id', 'created_at', 'description', 'id', 'min_stock', 'name', 'price', 'sku', 'slug', 'status', 'stock', 'updated_at', 'unit_id' ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ 'category', 'images', 'inventory_movements', 'purchases', 'product_images', 'unit', 'variants' ]
  end

  def vat_amount
    (price_base * vat_rate / 100.0).round(2)
  end

  def total_price
    (price_base + vat_amount).round(2)
  end
end
