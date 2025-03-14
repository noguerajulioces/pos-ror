# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create(name: 'Administrator', email: 'admin@admin.com', password: 123456)

# db/seeds.rb

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

company_settings = [
  {
    var: 'company_name',
    value: 'TU EMPRESA'
  },
  {
    var: 'company_owner',
    value: 'JUAN PEREZ PEREZ'
  },
  {
    var: 'company_address',
    value: 'RUTA 1 C/ AV. CABALLERO 1894, ENCARNACION'
  },
  {
    var: 'company_ruc',
    value: '000000000-0'
  },
  {
    var: 'receipt_final_message',
    value: '***¡Gracias por su compra!***'
  }
]

company_settings.each do |setting|
  Setting.set(setting[:var], setting[:value])
end
