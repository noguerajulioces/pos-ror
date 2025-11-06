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
account = Account.find_or_create_by!(name: 'Sucursal Ruta 1')

# Create roles
%w[superadmin vendedor cajero mesero].each { |n| Role.find_or_create_by!(name: n) }

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
  # Skip unit creation for now to avoid validation issues
  # unit = Unit.find_by(name: 'Pieza')
  # unit ||= Unit.create!(name: 'Pieza')

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
    existing_unit = Unit.find_by(name: unit_data[:name])
    if existing_unit
      existing_unit.update!(abbreviation: unit_data[:abbreviation]) if existing_unit.abbreviation != unit_data[:abbreviation]
    else
      Unit.create!(name: unit_data[:name], abbreviation: unit_data[:abbreviation])
    end
  end

  # Create main categories for Kombi Burger menu
  main_categories = [
    'Hamburguesas y Lomitos',
    'Pizzas y Empanadas',
    'Acompañamientos',
    'Picadas',
    'Bebidas'
  ]

  main_categories.each do |category_name|
    Category.find_or_create_by!(name: category_name)
  end

  # Create subcategories for Hamburguesas y Lomitos
  hamburguesas_lomitos_category = Category.find_by(name: 'Hamburguesas y Lomitos')
  hamburguesas_lomitos_subcategories = [
    'Hamburguesas',
    'Sandwich de lomo',
    'Lomito árabe',
    'Super Panchos'
  ]

  hamburguesas_lomitos_subcategories.each do |subcategory_name|
    Category.find_or_create_by!(name: subcategory_name, parent: hamburguesas_lomitos_category)
  end

  # Create subcategories for Pizzas y Empanadas
  pizzas_empanadas_category = Category.find_by(name: 'Pizzas y Empanadas')
  pizzas_empanadas_subcategories = [
    'Pizza',
    'Empanadas'
  ]

  pizzas_empanadas_subcategories.each do |subcategory_name|
    Category.find_or_create_by!(name: subcategory_name, parent: pizzas_empanadas_category)
  end

  # Create subcategories for Acompañamientos
  acompanamientos_category = Category.find_by(name: 'Acompañamientos')
  acompanamientos_subcategories = [
    'Papas fritas',
    'Gratinadas'
  ]

  acompanamientos_subcategories.each do |subcategory_name|
    Category.find_or_create_by!(name: subcategory_name, parent: acompanamientos_category)
  end

  # Create subcategories for Bebidas
  bebidas_category = Category.find_by(name: 'Bebidas')
  beverage_subcategories = [
    'Coca-Cola',
    'Aquarius',
    'Jugo del Valle',
    'Agua',
    'Otros'
  ]

  beverage_subcategories.each do |subcategory_name|
    Category.find_or_create_by!(name: subcategory_name, parent: bebidas_category)
  end

  # Create sample products for each category
  # Hamburguesas
  hamburguesas_category = Category.find_by(name: 'Hamburguesas')
  hamburguesas_products = [
    { name: 'La Kombi Supreme', price: 40000 },
    { name: 'Hamburguesa KB', price: 26000 },
    { name: 'Hamburguesa americana', price: 20000 },
    { name: 'Hamburguesa tradicional', price: 15000 },
    { name: 'Hamburguesa americanita', price: 10000 }
  ]

  hamburguesas_products.each_with_index do |product_data, index|
    sku = "HB-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = hamburguesas_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Sandwich de lomo
  sandwich_category = Category.find_by(name: 'Sandwich de lomo')
  sandwich_products = [
    { name: 'Sandwich de lomo KB', price: 30000 },
    { name: 'Sandwich tradicional', price: 25000 }
  ]

  sandwich_products.each_with_index do |product_data, index|
    sku = "SL-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = sandwich_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Lomito árabe
  lomito_category = Category.find_by(name: 'Lomito árabe')
  lomito_products = [
    { name: 'Lomito kombi', price: 30000 },
    { name: 'Lomito árabe', price: 25000 }
  ]

  lomito_products.each_with_index do |product_data, index|
    sku = "LA-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = lomito_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Pizza
  pizza_category = Category.find_by(name: 'Pizza')
  pizza_products = [
    { name: 'Mexicana', price: 65000 },
    { name: 'Napolitana especial', price: 65000 },
    { name: 'Pepperoni', price: 65000 },
    { name: 'Pollo con katupiry', price: 65000 },
    { name: 'Napolitana', price: 60000 },
    { name: 'Fugazzeta', price: 60000 },
    { name: 'Capresse', price: 60000 },
    { name: 'Choclo', price: 60000 },
    { name: 'Huevo', price: 60000 },
    { name: 'Jamón', price: 60000 },
    { name: 'Muzzarella', price: 55000 }
  ]

  pizza_products.each_with_index do |product_data, index|
    sku = "PZ-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = pizza_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
      product.description = 'Con borde + 15.000 Gs.'
    end
  end

  # Super Panchos
  pancho_category = Category.find_by(name: 'Super Panchos')
  Product.find_or_create_by!(sku: 'SP-SUPER') do |product|
    product.name = 'Super Pancho'
    product.category = pancho_category
    product.price = 10000
    product.status = 'active'
    product.kind = 'recipe'
  end

  # Picadas
  picadas_category = Category.find_by(name: 'Picadas')
  picadas_products = [
    { name: 'Picada Grande', price: 110000 },
    { name: 'Picada Chica', price: 60000 }
  ]

  picadas_products.each_with_index do |product_data, index|
    sku = "PC-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = picadas_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Papas fritas
  papas_category = Category.find_by(name: 'Papas fritas')
  papas_products = [
    { name: 'Papas fritas Grande', price: 22000 },
    { name: 'Papas fritas Mediano', price: 17000 },
    { name: 'Papas fritas Pequeña', price: 13000 }
  ]

  papas_products.each_with_index do |product_data, index|
    sku = "PF-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = papas_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Empanadas
  empanadas_category = Category.find_by(name: 'Empanadas')
  empanadas_products = [
    { name: 'Empanada Especial Kombi', price: 10000 },
    { name: 'Empanada Pollo especial', price: 10000 },
    { name: 'Empanada Carne - pollo Jamón y queso', price: 6000 },
    { name: 'Empanada Choclo - carne picante', price: 6000 }
  ]

  empanadas_products.each_with_index do |product_data, index|
    sku = "EM-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = empanadas_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Gratinadas
  gratinadas_category = Category.find_by(name: 'Gratinadas')
  gratinadas_products = [
    { name: 'Gratinada Grande', price: 30000 },
    { name: 'Gratinada Pequeña', price: 23000 }
  ]

  gratinadas_products.each_with_index do |product_data, index|
    sku = "GR-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = gratinadas_category
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'recipe'
    end
  end

  # Bebidas - Coca-Cola
  coca_cola_subcategory = Category.find_by(name: 'Coca-Cola')
  coca_cola_products = [
    { name: 'Coca cola 2 lts.', price: 17000 },
    { name: 'Coca cola 1,5 lts.', price: 14000 },
    { name: 'Coca cola 1 ltl.', price: 10000 },
    { name: 'Coca cola 500 ml.', price: 8000 },
    { name: 'Coca cola lata', price: 8000 },
    { name: 'Coca cola 250 ml.', price: 4000 }
  ]

  coca_cola_products.each_with_index do |product_data, index|
    sku = "CC-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = coca_cola_subcategory
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'simple'
    end
  end

  # Bebidas - Aquarius
  aquarius_subcategory = Category.find_by(name: 'Aquarius')
  aquarius_products = [
    { name: 'Aquarius 1,5 lts.', price: 13000 },
    { name: 'Aquarius 410 ml.', price: 7000 }
  ]

  aquarius_products.each_with_index do |product_data, index|
    sku = "AQ-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = aquarius_subcategory
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'simple'
    end
  end

  # Bebidas - Jugo del Valle
  jugo_subcategory = Category.find_by(name: 'Jugo del Valle')
  jugo_products = [
    { name: 'Jugo del valle 1 lt.', price: 12000 },
    { name: 'Jugo del valle 200 ml.', price: 4000 }
  ]

  jugo_products.each_with_index do |product_data, index|
    sku = "JV-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = jugo_subcategory
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'simple'
    end
  end

  # Bebidas - Agua
  agua_subcategory = Category.find_by(name: 'Agua')
  agua_products = [
    { name: 'Agua 2 lts.', price: 6000 },
    { name: 'Agua 1 lt.', price: 5000 },
    { name: 'Agua 500 ml.', price: 3000 }
  ]

  agua_products.each_with_index do |product_data, index|
    sku = "AG-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = agua_subcategory
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'simple'
    end
  end

  # Bebidas - Otros
  otros_subcategory = Category.find_by(name: 'Otros')
  otros_products = [
    { name: 'Powerade', price: 10000 },
    { name: 'Agua tónica 500 ml.', price: 10000 },
    { name: 'Schweppes 2 lt.', price: 17000 },
    { name: 'Schweppes', price: 8000 }
  ]

  otros_products.each_with_index do |product_data, index|
    sku = "OT-#{index + 1}"
    Product.find_or_create_by!(sku: sku) do |product|
      product.name = product_data[:name]
      product.category = otros_subcategory
      product.price = product_data[:price]
      product.status = 'active'
      product.kind = 'simple'
    end
  end
end
