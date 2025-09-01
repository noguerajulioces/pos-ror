# == Schema Information
#
# Table name: purchase_items
#
#  id               :bigint           not null, primary key
#  purchasable_type :string
#  quantity         :decimal(12, 3)
#  subtotal         :decimal(12, 2)
#  total_price      :decimal(, )
#  unit_price       :decimal(12, 2)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  purchasable_id   :bigint
#  purchase_id      :bigint           not null
#  unit_id          :bigint
#
# Indexes
#
#  index_purchase_items_on_account_id                           (account_id)
#  index_purchase_items_on_purchasable_type_and_purchasable_id  (purchasable_type,purchasable_id)
#  index_purchase_items_on_purchase_id                          (purchase_id)
#  index_purchase_items_on_unit_id                              (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (purchase_id => purchases.id)
#  fk_rails_...  (unit_id => units.id)
#
class PurchaseItem < ApplicationRecord
  acts_as_tenant(:account)

  include NumericFormatter

  sanitize_numeric_attributes :subtotal, :unit_price

  belongs_to :purchase
  belongs_to :purchasable, polymorphic: true
  belongs_to :unit, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :purchasable, presence: true

  before_validation :calculate_subtotal

  def self.ransackable_attributes(auth_object = nil)
    %w[id quantity unit_price subtotal created_at updated_at purchasable_type purchasable_id unit_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[purchase purchasable unit]
  end

  private

  def calculate_subtotal
    self.subtotal = (quantity || 0) * (unit_price || 0)
  end
end
