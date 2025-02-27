# == Schema Information
#
# Table name: sales
#
#  id             :bigint           not null, primary key
#  payment_method :string
#  status         :string
#  total_amount   :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Sale < ApplicationRecord
  has_many :sale_items
  has_many :products, through: :sale_items
end
