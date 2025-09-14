# == Schema Information
#
# Table name: combo_items
#
#  id                   :bigint           not null, primary key
#  deleted_at           :datetime
#  optional             :boolean          default(FALSE)
#  quantity             :decimal(12, 3)   default(1.0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  account_id           :bigint           not null
#  choice_group_id      :bigint
#  component_product_id :bigint           not null
#  product_id           :bigint           not null
#
# Indexes
#
#  index_combo_items_on_account_id                           (account_id)
#  index_combo_items_on_choice_group_id                      (choice_group_id)
#  index_combo_items_on_component_product_id                 (component_product_id)
#  index_combo_items_on_deleted_at                           (deleted_at)
#  index_combo_items_on_product_id                           (product_id)
#  index_combo_items_on_product_id_and_component_product_id  (product_id,component_product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (choice_group_id => modifier_groups.id)
#  fk_rails_...  (component_product_id => products.id)
#  fk_rails_...  (product_id => products.id)
#
class ComboItem < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :component_product_id, uniqueness: { scope: :product_id }

  # Asociaciones
  belongs_to :product
  belongs_to :component_product, class_name: 'Product'
  belongs_to :choice_group, class_name: 'ModifierGroup', optional: true

  # Scopes
  scope :required, -> { where(optional: false) }
  scope :optional, -> { where(optional: true) }

  # Métodos
  def deduct_component_stock(units_sold)
    total_needed = quantity * units_sold

    case component_product.kind
    when 'simple'
      component_product.deduct_stock(total_needed)
    when 'recipe'
      component_product.deduct_ingredients!(units: total_needed)
    when 'combo'
      component_product.deduct_combo_components!(units: total_needed)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[quantity optional created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[product component_product choice_group]
  end
end
