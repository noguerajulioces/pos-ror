# == Schema Information
#
#  id               :bigint           not null, primary key
#  cash_register_id :bigint           not null
#  amount           :decimal(10, 2)
#  movement_type    :string           # ingreso | egreso
#  reason           :string
#  created_at       :datetime         not null
#
class CashMovement < ApplicationRecord
  belongs_to :cash_register

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :movement_type, inclusion: { in: %w[ingreso egreso] }
end
