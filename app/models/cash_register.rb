# == Schema Information
#
# Table name: cash_registers
#
#  id             :bigint           not null, primary key
#  close_at       :datetime
#  final_amount   :decimal(, )
#  initial_amount :decimal(, )
#  open_at        :datetime
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_cash_registers_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class CashRegister < ApplicationRecord
  belongs_to :user

  validates :open_at, :initial_amount, :status, presence: true
  validates :initial_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :final_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Un scope para obtener la caja abierta
  scope :open, -> { where(status: "open") }

  # Método para cerrar la caja
  def close!(final_amount)
    update(close_at: Time.current, final_amount: final_amount, status: "closed")
  end
end
