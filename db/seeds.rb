# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create(name: 'Julio', email: 'noguerajulio24@gmail.com', password: 123456)

require 'faker'

# Crear 20 clientes fake
20.times do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  document   = Faker::Number.unique.number(digits: 8).to_s
  email      = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")
  address    = Faker::Address.street_address
  city       = Faker::Address.city
  country    = Faker::Address.country
  phone      = Faker::PhoneNumber.phone_number
  state      = Faker::Address.state
  zip_code   = Faker::Address.zip_code
  notes      = Faker::Lorem.sentence(word_count: 10)

  Customer.create!(
    first_name: first_name,
    last_name: last_name,
    document: document,
    email: email,
    address: address,
    city: city,
    country: country,
    phone: phone,
    state: state,
    zip_code: zip_code,
    notes: notes
  )
end

puts "Se han creado 20 clientes de prueba."
