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
  include NumericFormatter
  sanitize_numeric_attributes :final_amount, :initial_amount

  belongs_to :user
  belongs_to :cash_movement, optional: true

  validates :open_at, :initial_amount, :status, presence: true
  validates :initial_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :final_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :only_one_open_register_per_user, on: :create

  # Un scope para obtener la caja abierta
  scope :open, -> { where(status: 'open') }
  scope :from_today, -> { where(open_at: Time.current.beginning_of_day..Time.current.end_of_day) }

  # Método para cerrar la caja
  def close!(final_amount)
    update(close_at: Time.current, final_amount: final_amount, status: 'closed')
  end

  def only_one_open_register_per_user
    if user.cash_registers.open.exists?
      errors.add(:base, 'Ya existe una caja abierta para este usuario')
    end
  end

  def force_close!(final_amount, reason = nil)
    update(close_at: Time.current, final_amount: final_amount, status: 'forced_closed', closure_reason: reason)
  end

  def daily_report
    sales.includes(:products)
  end
end
