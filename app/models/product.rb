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
class Product < ApplicationRecord
  acts_as_tenant(:account)

  acts_as_paranoid
  include NumericFormatter
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Add manual_purchase_price to sanitized attributes
  sanitize_numeric_attributes :price, :manual_purchase_price

  # Asociaciones existentes
  belongs_to :category
  belongs_to :unit, optional: true
  belongs_to :tax_rate, optional: true
  has_many :sale_items
  has_many :inventory_movements, dependent: :destroy
  has_many :variants, class_name: 'ProductVariant', dependent: :destroy
  has_many :images, class_name: 'ProductImage', dependent: :destroy
  has_many :purchase_items, as: :purchasable, dependent: :nullify
  has_many :purchases, through: :purchase_items
  has_many :product_images, dependent: :destroy

  # Asociaciones para restaurante
  has_many :recipe_components, dependent: :destroy
  has_many :ingredients, through: :recipe_components
  has_many :combo_items, foreign_key: :product_id, dependent: :destroy
  has_many :components, through: :combo_items, source: :component_product
  has_many :modifier_groups_products, dependent: :destroy
  has_many :modifier_groups, through: :modifier_groups_products

  # Enums para restaurante
  enum :kind, { simple: 'simple', recipe: 'recipe', combo: 'combo', modifier: 'modifier' }
  enum :kitchen_station, { grill: 'grill', fryer: 'fryer', oven: 'oven', bar: 'bar' }, prefix: :station
  enum :status, { active: 'active', inactive: 'inactive', out_of_stock: 'out_of_stock' }

  # Validaciones
  validates :name, :price, :sku, presence: true
  validates :sku, uniqueness: true
  validates :prep_time_seconds, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :sort_order, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :recipe_must_have_components, if: :recipe?, unless: :skip_recipe_validation

  before_create :generate_barcode, if: -> { barcode.blank? }
  before_save :update_stock_status

  # Scopes existentes
  scope :available, -> { where(status: 'active') }
  scope :in_stock, -> { where(stock: 0..) }

  # Scopes para restaurante
  scope :by_kind, ->(kind) { where(kind: kind) }
  scope :by_kitchen_station, ->(station) { where(kitchen_station: station) }
  scope :by_menu_section, ->(section) { where(menu_section: section) }
  scope :featured, -> { where(is_featured: true) }
  scope :ordered, -> { order(:sort_order, :name) }
  scope :vegan, -> { where(is_vegan: true) }
  scope :vegetarian, -> { where(is_vegetarian: true) }
  scope :gluten_free, -> { where(is_gluten_free: true) }

  def update_average_cost(new_unit_price, new_quantity)
    current_avg   = (average_cost || 0)
    current_stock = (stock || 0)
    total_cost    = (current_avg * current_stock) + (new_unit_price * new_quantity)
    new_stock     = current_stock + new_quantity
    self.average_cost = new_stock.positive? ? (total_cost / new_stock) : 0
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
    if kind == 'recipe'
      recipe_service.calculate_recipe_cost
    else
      manual_purchase_price.presence || average_cost || 0
    end
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

  # Métodos para restaurante
  def price_with_tax
    return price unless tax_rate
    price * (1 + tax_rate.percentage / 100.0)
  end

  def deduct_ingredients!(units: 1)
    return unless recipe?

    recipe_components.each do |component|
      component.deduct_ingredient_stock(units)
    end
  end

  def deduct_combo_components!(units: 1)
    return unless combo?

    combo_items.each do |item|
      item.deduct_component_stock(units)
    end
  end

  def virtual_stock
    case kind
    when 'simple'
      stock
    when 'recipe'
      # Stock virtual basado en ingredientes disponibles
      recipe_components.map do |component|
        ingredient_stock = component.ingredient.stock
        (ingredient_stock / component.total_quantity_with_waste).floor
      end.min || 0
    when 'combo'
      # Stock virtual basado en componentes disponibles
      combo_items.map do |item|
        component_stock = item.component_product.virtual_stock || 0
        component_stock / item.quantity
      end.min || 0
    else
      0
    end
  end

  def prep_time_minutes
    return 0 unless prep_time_seconds
    (prep_time_seconds / 60.0).ceil
  end

  def display_name
    print_name.presence || name
  end

  def purchasable?
    respond_to?(:kind) ? kind == 'simple' : true
  end

  def stock_status
    if stock <= 0
      'out_of_stock'
    elsif min_stock && stock <= min_stock
      'low_stock'
    else
      'in_stock'
    end
  end

  def generate_barcode
    self.barcode = "PROD-#{SecureRandom.hex(6).upcase}"
  end

  def update_stock_status
    return if kind == 'combo' || stock.nil?
    self.status = stock <= 0 ? 'out_of_stock' : 'active'
  end

  def self.ransackable_attributes(auth_object = nil)
    [ 'average_cost', 'barcode', 'category_id', 'created_at', 'description', 'id', 'min_stock', 'name', 'price', 'sku', 'slug', 'status', 'stock', 'updated_at', 'unit_id', 'kind', 'kitchen_station', 'print_name', 'menu_section', 'prep_time_seconds', 'sort_order', 'is_featured', 'is_vegan', 'is_vegetarian', 'is_gluten_free', 'tax_rate_id' ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ 'category', 'images', 'inventory_movements', 'purchases', 'product_images', 'unit', 'variants', 'tax_rate', 'recipe_components', 'ingredients', 'combo_items', 'components', 'modifier_groups_products', 'modifier_groups' ]
  end

  # Métodos públicos para controlar validaciones
  def skip_recipe_validation
    @skip_recipe_validation
  end

  def skip_recipe_validation=(value)
    @skip_recipe_validation = value
  end

  # Métodos para productos tipo receta
  def recipe_service
    @recipe_service ||= ProductServices::RecipeService.new(self)
  end

  def can_produce?(quantity = 1)
    return true unless kind == 'recipe'
    recipe_service.validate_stock_availability(quantity)[:sufficient]
  end

  def max_producible_quantity
    return stock unless kind == 'recipe'
    recipe_service.calculate_max_producible_quantity
  end

  def produce!(quantity = 1)
    return false unless kind == 'recipe'
    return false unless can_produce?(quantity)

    result = recipe_service.deduct_ingredients_stock(quantity)
    if result[:success]
      # Agregar al stock del producto final
      self.stock += quantity
      save
    end
    result[:success]
  end

  def recipe_cost
    return 0 unless kind == 'recipe'
    recipe_service.calculate_recipe_cost
  end

  def recipe_summary
    return {} unless kind == 'recipe'
    recipe_service.recipe_summary
  end

  def critical_ingredients
    return [] unless kind == 'recipe'
    recipe_service.check_critical_ingredients
  end

  private

  def generate_barcode
    self.barcode = "PROD-#{SecureRandom.hex(6).upcase}"
  end

  def recipe_must_have_components
    return unless recipe?
    return if recipe_components.any?
    return if skip_recipe_validation

    # Solo validar si el producto ya existe y se está intentando activar/usar
    if persisted? && status == 'active'
      errors.add(:base, 'Los productos de receta activos deben tener al menos un ingrediente. Agrega ingredientes antes de activar el producto.')
    elsif persisted?
      # Para productos existentes pero inactivos, solo advertir
      errors.add(:base, 'Este producto de receta no tiene ingredientes. Agrégalos para poder activarlo y venderlo.')
    end
  end
end
