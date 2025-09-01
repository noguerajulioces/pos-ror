# == Schema Information
#
# Table name: modifier_groups_products
#
#  id                :bigint           not null, primary key
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint           not null
#  modifier_group_id :bigint           not null
#  product_id        :bigint           not null
#
# Indexes
#
#  index_modifier_groups_products_on_account_id         (account_id)
#  index_modifier_groups_products_on_deleted_at         (deleted_at)
#  index_modifier_groups_products_on_modifier_group_id  (modifier_group_id)
#  index_modifier_groups_products_on_product_id         (product_id)
#  index_modifier_groups_products_unique                (product_id,modifier_group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (modifier_group_id => modifier_groups.id)
#  fk_rails_...  (product_id => products.id)
#
class ModifierGroupsProduct < ApplicationRecord
  acts_as_tenant(:account)
  acts_as_paranoid

  # Validaciones
  validates :product_id, uniqueness: { scope: :modifier_group_id }

  # Asociaciones
  belongs_to :product
  belongs_to :modifier_group

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[product modifier_group]
  end
end
