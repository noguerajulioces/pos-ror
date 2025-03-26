# == Schema Information
#
# Table name: cash_movements
#
#  id               :bigint           not null, primary key
#  amount           :decimal(10, 2)   not null
#  movement_type    :string           not null
#  reason           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cash_register_id :bigint           not null
#
# Indexes
#
#  index_cash_movements_on_cash_register_id  (cash_register_id)
#
# Foreign Keys
#
#  fk_rails_...  (cash_register_id => cash_registers.id)
#
class CashMovement < ApplicationRecord
  belongs_to :cash_register

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :movement_type, inclusion: { in: %w[ingreso egreso] }
end
