# == Schema Information
#
# Table name: settings
#
#  id         :bigint           not null, primary key
#  value      :text
#  var        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Setting < ApplicationRecord
  validates :var, presence: true, uniqueness: true

  # Método de clase para obtener un setting por su variable
  def self.get(var)
    setting = find_by(var: var)
    setting.present? ? setting.value : nil
  end

  # Método de clase para establecer o actualizar un setting
  def self.set(var, value)
    setting = find_or_initialize_by(var: var)
    setting.value = value
    setting.save!
  end

  # Opcional: métodos para convertir el value a ciertos tipos
  def value_as_integer
    value.to_i
  end

  def value_as_float
    value.to_f
  end
end
