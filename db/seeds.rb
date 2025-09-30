# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create the main account
account = Account.find_or_create_by!(name: 'Sucursal 1')

# Create roles
%w[superadmin vendedor cajero].each { |n| Role.find_or_create_by!(name: n) }

# Create the admin user for this account
user = User.find_or_create_by!(email: 'admin@admin.com') do |u|
  u.name = 'Administrator'
  u.password = '123456'
  u.account_id = account.id
  u.super_user = true
  u.active = true
end

# Assign superadmin role to admin user
user.add_role :superadmin unless user.has_role?(:superadmin)

# Set the current tenant to the account for all subsequent operations
ActsAsTenant.with_tenant(account) do
  # Asegúrate de que exista una unidad para los productos
  unit = Unit.find_or_create_by!(name: 'Pieza')

  # Add currency seeds
  currencies = [
    { name: 'Dólar', code: 'USD', symbol: '$', exchange_rate: 7350, flag_url: 'https://flagcdn.com/w20/us.png', display: true },
    { name: 'Peso Argentino', code: 'ARS', symbol: '$', exchange_rate: 85.5, flag_url: 'https://flagcdn.com/w20/ar.png', display: true },
    { name: 'Real Brasileño', code: 'BRL', symbol: 'R$', exchange_rate: 1250, flag_url: 'https://flagcdn.com/w20/br.png', display: true },
    { name: 'Guarani', code: 'PYG', symbol: '₲', exchange_rate: 1, flag_url: 'https://flagcdn.com/w20/py.png', display: true }
  ]

  currencies.each do |currency_data|
    Currency.find_or_create_by!(code: currency_data[:code]) do |currency|
      currency.update(currency_data)
    end
  end

  # Company settings
  company_settings = [
    { var: 'company_name', value: 'TU EMPRESA' },
    { var: 'company_owner', value: 'JUAN PEREZ PEREZ' },
    { var: 'company_address', value: 'RUTA 1 C/ AV. CABALLERO 1894, ENCARNACION' },
    { var: 'company_ruc', value: '000000000-0' },
    { var: 'company_phone', value: '0975 000000' },
    { var: 'company_email', value: 'contacto@tuempresa.com' },
    { var: 'company_invoice_number', value: '001-002-0001516' },
    { var: 'company_stamp_number', value: '17304657' },
    { var: 'company_stamp_validity', value: '01/07/2024 al 31/07/2025' },
    { var: 'receipt_final_message', value: '***¡Gracias por su compra!***' },
    { var: 'company_economic_activity', value: 'VENTA DE PRODUCTOS ELECTRÓNICOS' }
  ]

  company_settings.each do |setting|
    Setting.set(setting[:var], setting[:value])
  end

  # Crear impuestos básicos
  tax_rates = [
    { name: 'IVA 10%', percentage: 10.0 },
    { name: 'IVA 5%', percentage: 5.0 },
    { name: 'Exento', percentage: 0.0 }
  ]

  tax_rates.each do |tax_data|
    TaxRate.find_or_create_by!(name: tax_data[:name]) do |tax|
      tax.percentage = tax_data[:percentage]
      tax.is_active = true
    end
  end

  # Crear unidades básicas para restaurante
  units = [
    { name: 'Gramo', abbreviation: 'g' },
    { name: 'Kilogramo', abbreviation: 'kg' },
    { name: 'Mililitro', abbreviation: 'ml' },
    { name: 'Litro', abbreviation: 'l' },
    { name: 'Unidad', abbreviation: 'un' }
  ]

  units.each do |unit_data|
    Unit.find_or_create_by!(name: unit_data[:name]) do |unit|
      unit.abbreviation = unit_data[:abbreviation]
    end
  end
end
