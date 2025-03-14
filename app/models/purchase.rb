# == Schema Information
#
# Table name: purchases
#
#  id            :bigint           not null, primary key
#  purchase_date :date
#  supplier      :string
#  total_amount  :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Purchase < ApplicationRecord
  has_many :purchase_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_items, allow_destroy: true
  has_many :products, through: :purchase_items
end
