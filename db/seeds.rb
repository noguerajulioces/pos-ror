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
account = Account.find_or_create_by!(name: 'Ferreteria el Rey')

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

  # Crear grupos de modificadores de ejemplo
  cheese_group = ModifierGroup.find_or_create_by!(name: 'Quesos') do |group|
    group.min_select = 0
    group.max_select = 2
    group.required = false
  end

  sauce_group = ModifierGroup.find_or_create_by!(name: 'Salsas') do |group|
    group.min_select = 1
    group.max_select = 1
    group.required = true
  end

  # Crear modificadores
  modifiers_data = [
    { name: 'Mozzarella', price_delta: 2000, group: cheese_group },
    { name: 'Parmesano', price_delta: 3000, group: cheese_group },
    { name: 'Salsa de Tomate', price_delta: 0, group: sauce_group },
    { name: 'Salsa BBQ', price_delta: 1000, group: sauce_group },
    { name: 'Salsa Picante', price_delta: 500, group: sauce_group }
  ]

  modifiers_data.each do |mod_data|
    Modifier.find_or_create_by!(name: mod_data[:name], modifier_group: mod_data[:group]) do |mod|
      mod.price_delta = mod_data[:price_delta]
    end
  end

  # Crear ingredientes base
  ingredients_data = [
    { name: 'Harina de Trigo', sku: 'ING001', unit: Unit.find_by(name: 'Kilogramo'), stock: 50.0, average_cost: 5000 },
    { name: 'Salsa de Tomate', sku: 'ING002', unit: Unit.find_by(name: 'Litro'), stock: 20.0, average_cost: 3000 },
    { name: 'Queso Mozzarella', sku: 'ING003', unit: Unit.find_by(name: 'Kilogramo'), stock: 15.0, average_cost: 25000 },
    { name: 'Aceite de Oliva', sku: 'ING004', unit: Unit.find_by(name: 'Litro'), stock: 10.0, average_cost: 15000 },
    { name: 'Sal', sku: 'ING005', unit: Unit.find_by(name: 'Gramo'), stock: 5000.0, average_cost: 100 }
  ]

  ingredients_data.each do |ing_data|
    Ingredient.find_or_create_by!(sku: ing_data[:sku]) do |ing|
      ing.name = ing_data[:name]
      ing.unit = ing_data[:unit]
      ing.stock = ing_data[:stock]
      ing.average_cost = ing_data[:average_cost]
      ing.min_stock = ing_data[:stock] * 0.1 # 10% del stock como mínimo
    end
  end

  # Crear categorías para restaurante
  categories_data = [
    { name: 'Pizzas' },
    { name: 'Bebidas' },
    { name: 'Combos' }
  ]

  categories_data.each do |cat_data|
    Category.find_or_create_by!(name: cat_data[:name])
  end

  # Crear producto simple: Coca 500ml
  coca_product = Product.find_or_create_by!(sku: 'PROD001') do |prod|
    prod.name = 'Coca Cola 500ml'
    prod.description = 'Bebida gaseosa Coca Cola 500ml'
    prod.price = 5000
    prod.stock = 100.0
    prod.category = Category.find_by(name: 'Bebidas')
    prod.unit = Unit.find_by(name: 'Unidad')
    prod.kind = 'simple'
    prod.kitchen_station = 'bar'
    prod.print_name = 'Coca 500ml'
    prod.menu_section = 'Bebidas'
    prod.prep_time_seconds = 0
    prod.sort_order = 1
    prod.availability_channels = [ 'salon', 'takeaway', 'delivery' ]
    prod.tax_rate = TaxRate.find_by(name: 'IVA 10%')
  end

  # Crear producto receta: Pizza Muzzarella (temporalmente como simple)
  pizza_product = Product.find_or_create_by!(sku: 'PROD002') do |prod|
    prod.name = 'Pizza Muzzarella'
    prod.description = 'Pizza tradicional con mozzarella y salsa de tomate'
    prod.price = 25000
    prod.stock = 0.0 # Stock Aproximado basado en ingredientes
    prod.category = Category.find_by(name: 'Pizzas')
    prod.unit = Unit.find_by(name: 'Unidad')
    prod.kind = 'simple' # Temporalmente simple
    prod.kitchen_station = 'oven'
    prod.print_name = 'Pizza Muzz'
    prod.menu_section = 'Pizzas'
    prod.prep_time_seconds = 900 # 15 minutos
    prod.sort_order = 1
    prod.availability_channels = [ 'salon', 'takeaway', 'delivery' ]
    prod.is_featured = true
    prod.tax_rate = TaxRate.find_by(name: 'IVA 10%')
  end

  # Crear componentes de receta para la pizza
  pizza_components_data = [
    { ingredient: Ingredient.find_by(name: 'Harina de Trigo'), quantity: 0.25, unit: Unit.find_by(name: 'Kilogramo') },
    { ingredient: Ingredient.find_by(name: 'Salsa de Tomate'), quantity: 0.1, unit: Unit.find_by(name: 'Litro') },
    { ingredient: Ingredient.find_by(name: 'Queso Mozzarella'), quantity: 0.15, unit: Unit.find_by(name: 'Kilogramo') },
    { ingredient: Ingredient.find_by(name: 'Aceite de Oliva'), quantity: 0.02, unit: Unit.find_by(name: 'Litro') },
    { ingredient: Ingredient.find_by(name: 'Sal'), quantity: 5.0, unit: Unit.find_by(name: 'Gramo') }
  ]

  pizza_components_data.each do |comp_data|
    RecipeComponent.find_or_create_by!(product: pizza_product, ingredient: comp_data[:ingredient]) do |rc|
      rc.quantity = comp_data[:quantity]
      rc.unit = comp_data[:unit]
      rc.waste_pct = 5.0 # 5% de desperdicio
    end
  end

  # Cambiar el tipo a recipe después de crear los componentes
  pizza_product.update!(kind: 'recipe')

  # Asociar grupos de modificadores a la pizza
  pizza_product.modifier_groups << cheese_group unless pizza_product.modifier_groups.include?(cheese_group)
  pizza_product.modifier_groups << sauce_group unless pizza_product.modifier_groups.include?(sauce_group)

  # Crear producto combo: Combo Clásico
  combo_product = Product.find_or_create_by!(sku: 'PROD003') do |prod|
    prod.name = 'Combo Clásico'
    prod.description = 'Pizza Muzzarella + Coca Cola 500ml'
    prod.price = 28000
    prod.stock = 0.0 # Stock Aproximado basado en componentes
    prod.category = Category.find_by(name: 'Combos')
    prod.unit = Unit.find_by(name: 'Unidad')
    prod.kind = 'combo'
    prod.kitchen_station = 'oven'
    prod.print_name = 'Combo Clásico'
    prod.menu_section = 'Combos'
    prod.prep_time_seconds = 900 # 15 minutos
    prod.sort_order = 1
    prod.availability_channels = [ 'salon', 'takeaway', 'delivery' ]
    prod.is_featured = true
    prod.tax_rate = TaxRate.find_by(name: 'IVA 10%')
  end

  # Crear items del combo
  combo_items_data = [
    { component: pizza_product, quantity: 1.0, optional: false },
    { component: coca_product, quantity: 1.0, optional: false }
  ]

  combo_items_data.each do |item_data|
    ComboItem.find_or_create_by!(product: combo_product, component_product: item_data[:component]) do |ci|
      ci.quantity = item_data[:quantity]
      ci.optional = item_data[:optional]
    end
  end

  puts "✅ Seeds de restaurante creados exitosamente!"
  puts "📊 Productos creados:"
  puts "   - #{coca_product.name} (Simple)"
  puts "   - #{pizza_product.name} (Receta)"
  puts "   - #{combo_product.name} (Combo)"
  puts "📋 Ingredientes: #{Ingredient.count}"
  puts "🧀 Modificadores: #{Modifier.count}"
  puts "💰 Impuestos: #{TaxRate.count}"

  # ===========================
  # CONFIGURACIÓN DE IMPRESORA
  # ===========================

  puts "🖨️ Configurando impresora térmica..."

  # Configuraciones de impresora térmica (solo las que se usan)
  printer_settings = {
    'printer_line_width_chars' => '48',         # Caracteres por línea
    'printer_windows_name' => 'Generic / Text Only', # Nombre en Windows
    'printer_lines_before_cut' => '3',         # Líneas antes del corte
    'printer_cut_command' => '\x1D\x56\x00'    # Comando corte completo
  }

  printer_settings.each do |key, value|
    setting = Setting.find_or_create_by(var: key) do |s|
      s.value = value
      s.account = Account.first
    end

    # Actualizar valor si ya existe
    if setting.persisted? && setting.value != value
      setting.update!(value: value)
    end

    puts "  ✓ #{key}: #{value}"
  end

  puts "🖨️ Configuraciones de impresora: #{printer_settings.count}"
end
