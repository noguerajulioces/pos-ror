# == Schema Information
#
# Table name: recipe_components
#
#  id            :bigint           not null, primary key
#  deleted_at    :datetime
#  quantity      :decimal(12, 3)   not null
#  waste_pct     :decimal(5, 2)    default(0.0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  ingredient_id :bigint           not null
#  product_id    :bigint           not null
#  unit_id       :bigint           not null
#
# Indexes
#
#  index_recipe_components_on_account_id                    (account_id)
#  index_recipe_components_on_deleted_at                    (deleted_at)
#  index_recipe_components_on_ingredient_id                 (ingredient_id)
#  index_recipe_components_on_product_id                    (product_id)
#  index_recipe_components_on_product_id_and_ingredient_id  (product_id,ingredient_id) UNIQUE
#  index_recipe_components_on_unit_id                       (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (unit_id => units.id)
#
class RecipeComponent < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :waste_pct, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :ingredient_id, uniqueness: { scope: :product_id }

  # Asociaciones
  belongs_to :product
  belongs_to :ingredient
  belongs_to :unit

  # Callbacks
  before_save :ensure_ingredient_stock

  # Métodos
  def total_quantity_with_waste
    quantity * (1 + waste_pct / 100.0)
  end

  def deduct_ingredient_stock(units_sold)
    total_needed = total_quantity_with_waste * units_sold
    ingredient.deduct_stock(total_needed)
  end

  private

  def ensure_ingredient_stock
    # Validación opcional: verificar que hay suficiente stock
    # Se puede implementar según las reglas de negocio
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[quantity waste_pct created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[product ingredient unit]
  end
end
