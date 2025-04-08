# == Schema Information
#
# Table name: payment_methods
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#
# Indexes
#
#  index_payment_methods_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class PaymentMethod < ApplicationRecord
  acts_as_tenant(:account)

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end
