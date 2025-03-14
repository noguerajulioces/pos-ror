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
  # Add default scope at the top of the model
  default_scope { order(:var) }

  validates :var, presence: true, uniqueness: true

  def self.get(var)
    setting = find_by(var: var)
    setting.present? ? setting.value : nil
  end

  def self.set(var, value)
    setting = find_or_initialize_by(var: var)
    setting.value = value
    setting.save!
  end

  def value_as_integer
    value.to_i
  end

  def value_as_float
    value.to_f
  end

  # Add these methods for the form
  def label
    var.humanize
  end

  def description
    # You can add descriptions in a hash if needed
    descriptions = {
      'company_name' => 'Nombre de la empresa que aparecerá en los recibos',
      'company_owner' => 'Nombre del propietario de la empresa',
      'company_address' => 'Dirección completa de la empresa',
      'company_ruc' => 'RUC de la empresa',
      'receipt_final_message' => 'Mensaje que aparece al final de cada recibo'
    }
    descriptions[var] || var.humanize
  end

  def boolean?
    value.to_s.match?(/^(true|false|1|0)$/i)
  end
end
