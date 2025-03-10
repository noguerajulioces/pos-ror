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

# categorias

parent_categories = {
  "Herramientas eléctricas" => [ "Taladros", "Sierras eléctricas", "Amoladoras" ],
  "Herramientas manuales" => [ "Martillos", "Destornilladores", "Llaves de vaso" ],
  "Materiales de construcción" => [ "Cemento", "Ladrillos", "Arena y grava" ],
  "Fontanería" => [ "Tubos y conexiones", "Griferías", "Accesorios de baño" ],
  "Electricidad" => [ "Cables y conductores", "Interruptores", "Iluminación" ],
  "Jardinería" => [ "Cortacéspedes", "Herramientas de jardín", "Sistemas de riego" ],
  "Seguridad y protección" => [ "Equipos de protección", "Alarmas", "Cámaras de seguridad" ],
  "Pinturas y recubrimientos" => [ "Pinturas", "Barnices", "Disolventes" ],
  "Accesorios y ferretería general" => [ "Fijaciones", "Abrazaderas", "Tornillería" ],
  "Muebles y decoración" => [ "Muebles de exterior", "Decoración interior", "Iluminación decorativa" ]
}

parent_categories.each do |parent_name, subcategories|
  parent = Category.create!(name: parent_name)
  subcategories.each do |child_name|
    Category.create!(name: child_name, parent: parent)
  end
end

puts "Se han creado #{Category.count} categorías (incluyendo padres e hijos)."


# db/seeds.rb

# Asegúrate de que exista una unidad para los productos
unit = Unit.find_or_create_by!(name: 'Pieza')

# Recorremos todas las categorías y creamos productos
Category.all.each do |category|
  3.times do |i|
    # Seleccionar un nombre de producto basado en la categoría (se usa un case para dar ejemplos concretos)
    product_name = case category.name
    when /Herramientas eléctricas/i
                     [ "Taladro inalámbrico", "Sierra circular", "Amoladora angular" ].sample
    when /Herramientas manuales/i
                     [ "Martillo", "Destornillador de precisión", "Juego de llaves" ].sample
    when /Materiales de construcción/i
                     [ "Cemento Portland", "Ladrillo refractario", "Arena fina" ].sample
    when /Fontanería/i
                     [ "Tubos PVC", "Grifería moderna", "Llave de paso" ].sample
    when /Electricidad/i
                     [ "Cable eléctrico", "Interruptor", "Enchufe resistente" ].sample
    when /Jardinería/i
                     [ "Cortacésped", "Podadora", "Manguera flexible" ].sample
    when /Seguridad y protección/i
                     [ "Detector de humo", "Extintor", "Cámara de seguridad" ].sample
    when /Pinturas y recubrimientos/i
                     [ "Pintura acrílica", "Barniz protector", "Disolvente ecológico" ].sample
    when /Accesorios y ferretería general/i
                     [ "Tornillos", "Abrazaderas", "Fijaciones para madera" ].sample
    when /Muebles y decoración/i
                     [ "Mueble de exterior", "Lámpara decorativa", "Estantería modular" ].sample
    else
                     "#{category.name} Producto #{i+1}"
    end

    Product.create!(
      name: product_name,
      sku: "#{category.name[0..2].upcase}-#{i+1}-#{SecureRandom.hex(2).upcase}",
      price: rand(50_000..500_000),                # Precio aleatorio entre 50 y 500
      average_cost: rand(30_000..400_000),          # Costo promedio aleatorio entre 30 y 400
      stock: rand(10..100),                 # Stock aleatorio entre 10 y 100
      min_stock: rand(5..10),               # Stock mínimo aleatorio entre 5 y 10
      description: "Producto ideal para la categoría #{category.name}: #{product_name}.",
      category: category,
      unit: unit,
      status: "active"
    )
  end
end

puts "Se han creado #{Product.count} productos."
