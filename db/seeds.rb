# frozen_string_literal: true

puts "🌱 Starting seeds..."

# ============================================
# 1. USERS
# ============================================
puts "👤 Creating users..."
admin = User.create!(
  name: 'Administrator',
  email: 'admin@admin.com',
  password: '123456',
  password_confirmation: '123456'
)

cashier = User.create!(
  name: 'Cajero Demo',
  email: 'cashier@example.com',
  password: '123456',
  password_confirmation: '123456'
)

# ============================================
# 2. SETTINGS
# ============================================
puts "⚙️  Creating settings..."
company_settings = [
  { var: 'company_name', value: 'TU EMPRESA' },
  { var: 'company_owner', value: 'JUAN PEREZ PEREZ' },
  { var: 'company_address', value: 'RUTA 1 C/ AV. CABALLERO 1894, ENCARNACION' },
  { var: 'company_ruc', value: '80012345-6' },
  { var: 'company_phone', value: '0975 123456' },
  { var: 'company_email', value: 'contacto@tuempresa.com' },
  { var: 'company_invoice_number', value: '001-002-0001516' },
  { var: 'company_stamp_number', value: '17304657' },
  { var: 'company_stamp_validity', value: '01/07/2024 al 31/07/2025' },
  { var: 'company_tax_stamp', value: '17304657' },
  { var: 'company_economic_activity', value: 'VENTA DE PRODUCTOS ELECTRÓNICOS' },
  { var: 'receipt_final_message', value: '***¡Gracias por su compra!***' }
]

company_settings.each do |setting|
  Setting.set(setting[:var], setting[:value])
end

# ============================================
# 3. CURRENCIES
# ============================================
puts "💱 Creating currencies..."
currencies_data = [
  { name: 'Guaraní', code: 'PYG', symbol: '₲', exchange_rate: 1, flag_url: 'https://flagcdn.com/w20/py.png', display: true },
  { name: 'Dólar', code: 'USD', symbol: '$', exchange_rate: 7350, flag_url: 'https://flagcdn.com/w20/us.png', display: true },
  { name: 'Peso Argentino', code: 'ARS', symbol: '$', exchange_rate: 85.5, flag_url: 'https://flagcdn.com/w20/ar.png', display: true },
  { name: 'Real Brasileño', code: 'BRL', symbol: 'R$', exchange_rate: 1250, flag_url: 'https://flagcdn.com/w20/br.png', display: true }
]

currencies_data.each do |currency_data|
  Currency.find_or_create_by!(code: currency_data[:code]) do |currency|
    currency.update!(currency_data)
  end
end

# ============================================
# 4. PAYMENT METHODS
# ============================================
puts "💳 Creating payment methods..."
payment_methods = ['Efectivo', 'Tarjeta de Crédito', 'Tarjeta de Débito', 'Transferencia', 'QR Bancario']
payment_methods.each do |method|
  PaymentMethod.create!(name: method, active: true)
end

# ============================================
# 5. UNITS
# ============================================
puts "📦 Creating units..."
units_data = ['Pieza', 'Kg', 'Litro', 'Metro', 'Caja', 'Paquete', 'Docena']
units_data.each do |unit_name|
  Unit.create!(name: unit_name)
end

unit_pieza = Unit.find_by(name: 'Pieza')

# ============================================
# 6. CATEGORIES
# ============================================
puts "📂 Creating categories..."
electronics = Category.create!(name: 'Electrónica')
food = Category.create!(name: 'Alimentos')
clothing = Category.create!(name: 'Ropa')
home = Category.create!(name: 'Hogar')

# Subcategories
Category.create!(name: 'Celulares', parent: electronics)
Category.create!(name: 'Computadoras', parent: electronics)
Category.create!(name: 'Accesorios', parent: electronics)

Category.create!(name: 'Bebidas', parent: food)
Category.create!(name: 'Snacks', parent: food)

Category.create!(name: 'Hombre', parent: clothing)
Category.create!(name: 'Mujer', parent: clothing)

# ============================================
# 7. SUPPLIERS
# ============================================
puts "🏢 Creating suppliers..."
suppliers_data = [
  { company_name: 'Distribuidora Central', document: '80123456-7', contact_name: 'Carlos Mendez', phone: '0981234567', email: 'carlos@distribuidora.com' },
  { company_name: 'Importadora Sur', document: '80234567-8', contact_name: 'Maria Lopez', phone: '0982345678', email: 'maria@importadora.com' },
  { company_name: 'Productos del Este', document: '80345678-9', contact_name: 'Pedro Ramirez', phone: '0983456789', email: 'pedro@productos.com' }
]

suppliers = suppliers_data.map { |data| Supplier.create!(data) }

# ============================================
# 8. CUSTOMERS
# ============================================
puts "👥 Creating customers..."
customers_data = [
  { first_name: 'Juan', last_name: 'García', document: '4123456', email: 'juan.garcia@example.com', phone: '0971234567', address: 'Av. España 123' },
  { first_name: 'María', last_name: 'Rodríguez', document: '4234567', email: 'maria.rodriguez@example.com', phone: '0972345678', address: 'Calle Palma 456' },
  { first_name: 'Carlos', last_name: 'Fernández', document: '4345678', email: 'carlos.fernandez@example.com', phone: '0973456789', address: 'Av. Mariscal López 789' },
  { first_name: 'Ana', last_name: 'Martínez', document: '4456789', email: 'ana.martinez@example.com', phone: '0974567890', address: 'Calle Cerro Corá 321' },
  { first_name: 'Luis', last_name: 'González', document: '4567890', email: 'luis.gonzalez@example.com', phone: '0975678901', address: 'Av. Eusebio Ayala 654' }
]

customers = customers_data.map { |data| Customer.create!(data) }

# ============================================
# 9. PRODUCTS
# ============================================
puts "📱 Creating products..."
products_data = [
  { name: 'Samsung Galaxy A54', sku: 'SAMG-A54', price: 2500000, stock: 15, category: Category.find_by(name: 'Celulares'), unit: unit_pieza, description: 'Smartphone Samsung últimomodelo' },
  { name: 'iPhone 13', sku: 'APPL-IP13', price: 4500000, stock: 8, category: Category.find_by(name: 'Celulares'), unit: unit_pieza, description: 'iPhone 13 128GB' },
  { name: 'Laptop HP Pavilion', sku: 'HP-PAV15', price: 3800000, stock: 5, category: Category.find_by(name: 'Computadoras'), unit: unit_pieza, description: 'Laptop HP Pavilion 15"' },
  { name: 'Mouse Logitech', sku: 'LOG-M190', price: 45000, stock: 50, category: Category.find_by(name: 'Accesorios'), unit: unit_pieza, description: 'Mouse inalámbrico' },
  { name: 'Teclado Mecánico', sku: 'KEY-MEC01', price: 250000, stock: 20, category: Category.find_by(name: 'Accesorios'), unit: unit_pieza, description: 'Teclado mecánico RGB' },
  { name: 'Coca Cola 2L', sku: 'COCA-2L', price: 12000, stock: 100, category: Category.find_by(name: 'Bebidas'), unit: unit_pieza, description: 'Coca Cola 2 litros' },
  { name: 'Agua Mineral 500ml', sku: 'AGUA-500', price: 3500, stock: 200, category: Category.find_by(name: 'Bebidas'), unit: unit_pieza, description: 'Agua mineral sin gas' },
  { name: 'Papas Fritas Pringles', sku: 'PRIN-ORG', price: 18000, stock: 75, category: Category.find_by(name: 'Snacks'), unit: unit_pieza, description: 'Papas Pringles original' },
  { name: 'Remera Nike', sku: 'NIKE-REM01', price: 150000, stock: 30, category: Category.find_by(name: 'Hombre'), unit: unit_pieza, description: 'Remera Nike deportiva' },
  { name: 'Jean Levis 501', sku: 'LEVI-501', price: 320000, stock: 25, category: Category.find_by(name: 'Hombre'), unit: unit_pieza, description: 'Jean Levis clásico' }
]

products = products_data.map { |data| Product.create!(data) }

# ============================================
# 10. CASH REGISTER
# ============================================
puts "💰 Creating cash register..."
cash_register = CashRegister.create!(
  user: admin,
  status: 'open',
  initial_amount: 500000,
  open_at: Time.current
)

# ============================================
# 11. PURCHASES
# ============================================
puts "🛒 Creating purchases..."
2.times do |i|
  purchase = Purchase.create!(
    supplier: suppliers.sample,
    purchase_date: i.days.ago,
    total_amount: 0
  )

  # Add purchase items
  3.times do
    product = products.sample
    quantity = rand(5..20)
    unit_price = product.price * 0.7 # Purchase price is 70% of selling price
    total_price = unit_price * quantity

    PurchaseItem.create!(
      purchase: purchase,
      product: product,
      quantity: quantity,
      unit_price: unit_price,
      total_price: total_price
    )
  end

  purchase.update!(total_amount: purchase.purchase_items.sum(:total_price))
end

# ============================================
# 12. ORDERS
# ============================================
puts "🛍️  Creating orders..."
10.times do |i|
  order = Order.create!(
    user: [admin, cashier].sample,
    customer: [nil, *customers].sample,
    payment_method: PaymentMethod.all.sample,
    order_date: rand(7).days.ago,
    status: ['completed', 'completed', 'completed', 'on_hold', 'cancelled'].sample,
    order_type: ['in_store', 'delivery'].sample,
    total_amount: 0,
    discount_percentage: [0, 0, 0, 5, 10].sample
  )

  # Add order items
  rand(1..5).times do
    product = products.sample
    quantity = rand(1..3)
    price = product.price

    OrderItem.create!(
      order: order,
      product: product,
      quantity: quantity,
      price: price,
      subtotal: quantity * price
    )
  end

  # Calculate total
  subtotal = order.order_items.sum(:subtotal)
  discount = order.discount_percentage.to_f > 0 ? (subtotal * order.discount_percentage / 100) : 0
  order.update!(total_amount: subtotal - discount)

  # Create payment if completed
  if order.status == 'completed'
    OrderPayment.create!(
      order: order,
      payment_method: order.payment_method,
      amount: order.total_amount,
      payment_date: order.order_date
    )

    # Create inventory movements for completed orders
    order.order_items.each do |item|
      InventoryMovement.create!(
        product: item.product,
        movement_type: 'sale',
        quantity: -item.quantity,
        reason: "Venta ##{order.id}",
        skip_stock_update: false
      )
    end
  end
end

# ============================================
# 13. CASH MOVEMENTS
# ============================================
puts "💵 Creating cash movements..."
5.times do
  CashMovement.create!(
    cash_register: cash_register,
    movement_type: ['ingreso', 'egreso'].sample,
    amount: rand(10000..100000),
    reason: ['Venta adicional', 'Pago a proveedor', 'Retiro para cambio', 'Depósito'].sample
  )
end

# ============================================
# 14. EXPENSES
# ============================================
puts "📝 Creating expenses..."
expense_categories = ['rent', 'utilities', 'salaries', 'maintenance', 'marketing']
5.times do
  category = expense_categories.sample
  Expense.create!(
    description: "#{category.humanize} - #{Date.current.strftime('%B %Y')}",
    amount: rand(500000..2000000),
    expense_date: rand(30).days.ago,
    category: category
  )
end

puts "✅ Seeds completed successfully!"
puts ""
puts "📊 Summary:"
puts "  Users: #{User.count}"
puts "  Customers: #{Customer.count}"
puts "  Suppliers: #{Supplier.count}"
puts "  Products: #{Product.count}"
puts "  Categories: #{Category.count}"
puts "  Orders: #{Order.count}"
puts "  Order Items: #{OrderItem.count}"
puts "  Purchases: #{Purchase.count}"
puts "  Cash Registers: #{CashRegister.count}"
puts "  Expenses: #{Expense.count}"
puts ""
puts "🔐 Login credentials:"
puts "  Admin: admin@admin.com / 123456"
puts "  Cashier: cashier@example.com / 123456"
