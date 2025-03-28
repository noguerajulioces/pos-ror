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
    descriptions = {
      'company_name' => 'Nombre de la empresa que aparecerá en los recibos',
      'company_owner' => 'Nombre del propietario de la empresa',
      'company_address' => 'Dirección completa de la empresa',
      'company_ruc' => 'RUC de la empresa',
      'company_phone' => 'Teléfono de la empresa que aparece en el recibo',
      'company_email' => 'Correo electrónico de contacto de la empresa',
      'company_invoice_number' => 'Número de factura que aparece en los comprobantes',
      'company_stamp_number' => 'Número de timbrado habilitado por la SET (TIMBRADO)',
      'company_stamp_validity' => 'Vigencia del timbrado (ej: 01/01/2024 al 31/12/2025)',
      'receipt_final_message' => 'Mensaje que aparece al final de cada recibo'
    }
    descriptions[var] || var.humanize
  end

  def boolean?
    value.to_s.match?(/^(true|false|1|0)$/i)
  end
end
