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

  include NumericFormatter
  sanitize_numeric_attributes :stock, :min_stock, :average_cost

  # Validaciones
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :sku, uniqueness: { scope: :account_id }, allow_blank: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :min_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :average_cost, numericality: { greater_than_or_equal_to: 0 }
  validate :initial_stock_must_have_cost

  # Asociaciones
  belongs_to :unit
  has_many :inventory_movements, as: :item, dependent: :destroy
  has_many :recipe_components, dependent: :destroy
  has_many :products, through: :recipe_components
  has_many :purchase_items, as: :purchasable, dependent: :nullify

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :low_stock, -> { where('min_stock IS NOT NULL AND stock <= min_stock') }
  scope :out_of_stock, -> { where(stock: 0) }

  # Callbacks
  after_initialize :set_default_numeric_values, if: :new_record?
  after_save :update_recipes_status

  # Métodos
  def stock_status
    return 'out_of_stock' if stock.zero?
    return 'low_stock' if min_stock && stock <= min_stock
    'in_stock'
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

  private

  def set_default_numeric_values
    self.stock ||= 0
    self.min_stock ||= 0
    self.average_cost ||= 0
  end

  def initial_stock_must_have_cost
    return unless new_record? # Solo para ingredientes nuevos
    return if stock.blank? || stock <= 0 # Si no hay stock inicial, no necesita costo

    if average_cost.blank? || average_cost <= 0
      errors.add(:average_cost, 'debe ser mayor a cero cuando hay stock inicial')
    end
  end

  def update_recipes_status
    # Update status of recipes that use this ingredient
    products.each do |recipe|
      next unless recipe.recipe? # Only update recipes

      recipe.update_stock_status
      recipe.save if recipe.changed?
    end
  end
end
