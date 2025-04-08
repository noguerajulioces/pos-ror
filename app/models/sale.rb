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
#  account_id     :bigint           not null
#
# Indexes
#
#  index_sales_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Sale < ApplicationRecord
  acts_as_tenant(:account)

  has_many :sale_items
  has_many :products, through: :sale_items
end
