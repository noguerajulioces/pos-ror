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
  scope :from_previous_days, -> { open.where('open_at < ?', Time.current.beginning_of_day) }

  # Método para cerrar la caja
  def close!(final_amount)
    update(close_at: Time.current, final_amount: final_amount, status: 'closed')
  end

  def only_one_open_register_per_user
    if user.cash_registers.open.exists?
      errors.add(:base, 'Ya existe una caja abierta para este usuario')
    end
  end

  def force_close!(final_amount)
    update(close_at: nil, final_amount: final_amount, status: 'forced_closed')
  end

  def daily_report
    sales.includes(:products)
  end

  # Método para verificar y cerrar cajas abiertas de días anteriores
  def self.auto_close_previous_day_registers
    from_previous_days.find_each do |register|
      # Since there's no direct cash_register_id in orders, we need to find orders
      # created during the time this register was open
      # Assuming orders are associated with the register's time period
      order_time_range = register.open_at..(register.close_at || Time.current)
      
      # Find orders created by this user during the register's open period
      total_sales_amount = Order.where(
        user_id: register.user_id,
        created_at: order_time_range
      ).sum(:total_amount) || 0
      
      # El monto final debería ser el monto inicial más las ventas
      final_amount = register.initial_amount + total_sales_amount
      
      # Cerrar forzadamente la caja con el monto calculado
      register.force_close!(final_amount)
    end
  end

  # Método para verificar si hay cajas abiertas de días anteriores
  def self.has_previous_day_open_registers?
    from_previous_days.exists?
  end

  def self.ransackable_attributes(auth_object = nil)
    [ 'close_at', 'created_at', 'final_amount', 'id', 'initial_amount', 'open_at', 'status', 'updated_at', 'user_id' ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ 'cash_movement', 'user' ]
  end
end
