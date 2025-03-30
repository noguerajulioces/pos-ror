# == Schema Information
#
# Table name: purchases
#
#  id            :bigint           not null, primary key
#  purchase_date :date
#  total_amount  :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  supplier_id   :bigint
#
# Indexes
#
#  index_purchases_on_supplier_id  (supplier_id)
#
# Foreign Keys
#
#  fk_rails_...  (supplier_id => suppliers.id)
#
class Purchase < ApplicationRecord
  include NumericFormatter

  sanitize_numeric_attributes :total_amount

  belongs_to :supplier
  has_many :purchase_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_items, allow_destroy: true
  has_many :products, through: :purchase_items

  def self.ransackable_attributes(auth_object = nil)
    [ 'id', 'purchase_date', 'total_amount', 'created_at', 'updated_at' ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ 'supplier' ]
  end
end
