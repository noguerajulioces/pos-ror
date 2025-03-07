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
#
class PaymentMethod < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end
