# == Schema Information
#
# Table name: ingredients
#
#  id           :bigint           not null, primary key
#  average_cost :decimal(12, 2)   default(0.0)
#  deleted_at   :datetime
#  min_stock    :decimal(12, 3)   default(0.0)
#  name         :string           not null
#  sku          :string
#  stock        :decimal(12, 3)   default(0.0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint           not null
#  unit_id      :bigint           not null
#
# Indexes
#
#  index_ingredients_on_account_id  (account_id)
#  index_ingredients_on_deleted_at  (deleted_at)
#  index_ingredients_on_name        (name)
#  index_ingredients_on_sku         (sku)
#  index_ingredients_on_unit_id     (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (unit_id => units.id)
#
class Ingredient < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :name, presence: true
  validates :sku, uniqueness: { scope: :account_id }, allow_blank: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :min_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :average_cost, numericality: { greater_than_or_equal_to: 0 }

  # Asociaciones
  belongs_to :unit
  has_many :recipe_components, dependent: :destroy
  has_many :products, through: :recipe_components
  has_many :purchase_items, as: :purchasable, dependent: :nullify

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :low_stock, -> { where('min_stock IS NOT NULL AND stock <= min_stock') }
  scope :out_of_stock, -> { where(stock: 0) }

  # Callbacks
  before_save :update_stock_status

  # Métodos
  def stock_status
    return 'out_of_stock' if stock.zero?
    return 'low_stock' if min_stock && stock <= min_stock
    'in_stock'
  end

  def update_stock_status
    # Método para futuras implementaciones de alertas
  end

  def deduct_stock(quantity)
    return false if stock < quantity

    self.stock -= quantity
    save
  end

  def add_stock(quantity, unit_price = nil)
    if unit_price.present?
      update_average_cost(unit_price, quantity)
    else
      self.stock += quantity
      save
    end
  end

  def update_average_cost(new_unit_price, new_quantity)
    current_avg   = (average_cost || 0)
    current_stock = (stock || 0)
    total_cost    = (current_avg * current_stock) + (new_unit_price * new_quantity)
    new_stock     = current_stock + new_quantity

    self.average_cost = new_stock.positive? ? (total_cost / new_stock) : 0
    self.stock = new_stock
    save
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name sku stock min_stock average_cost created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[unit recipe_components products]
  end
end
