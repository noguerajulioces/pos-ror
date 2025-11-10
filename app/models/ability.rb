# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Superadmin: acceso total
    if user.has_role?(:superadmin)
      can :manage, :all
      can :access, :admin_panel
      can :manage, User
      can :manage, :reports
      can :manage, :settings
      can :manage, :cash_registers
      can :manage, :products
      can :manage, :orders
      can :manage, :customers
      can :manage, :suppliers
      can :manage, :categories
      can :manage, :ingredients
      can :manage, :units
      can :manage, :currencies
      can :manage, :payment_methods
      can :manage, :expenses
      can :manage, :purchases
      can :manage, :stocks
      can :manage, :combos
      can :manage, :recipes
      can :manage, :simple_products
      can :manage, Role
    end

    # Vendedor: puede crear órdenes y ver productos
    if user.has_role?(:vendedor)
      can :read, :pos
      can :read, Product
      can [ :read, :create ], Order
      can :read, Customer
      can :read, PaymentMethod
      can :read, Category
      can :read, :cart
      can :manage, :cart_items
      cannot :destroy, Order
      cannot :access, :admin_panel
      cannot :manage, User
      cannot :manage, :reports
      cannot :manage, :settings
      cannot :manage, :cash_registers
      cannot :manage, :suppliers
      cannot :manage, :ingredients
      cannot :manage, :units
      cannot :manage, :currencies
      cannot :manage, :expenses
      cannot :manage, :purchases
      cannot :manage, :stocks
      cannot :manage, :combos
      cannot :manage, :recipes
      cannot :manage, :simple_products
    end

    # Cajero: puede ver órdenes y gestionar caja
    if user.has_role?(:cajero)
      can :read, :pos
      can :read, Order
      can :read, Product
      can :read, Customer
      can :read, PaymentMethod
      can :read, Category
      can [ :open, :close ], CashRegister
      can :read, :cash_registers
      can :read, :reports
      cannot :create, Order
      cannot :destroy, Order
      cannot :access, :admin_panel
      cannot :manage, User
      cannot :manage, :settings
      cannot :manage, :suppliers
      cannot :manage, :ingredients
      cannot :manage, :units
      cannot :manage, :currencies
      cannot :manage, :expenses
      cannot :manage, :purchases
      cannot :manage, :stocks
      cannot :manage, :combos
      cannot :manage, :recipes
      cannot :manage, :simple_products
    end

    # Mesero: puede crear órdenes en espera pero NO puede pagar ni gestionar caja
    if user.has_role?(:mesero)
      can :read, :pos
      can :read, Product
      can [ :read, :create ], Order
      can :read, Customer
      can :read, Category
      can :read, Table
      can :read, :cart
      can :manage, :cart_items
      cannot :pay, Order  # No puede procesar pagos
      cannot :destroy, Order
      cannot :access, :admin_panel
      cannot :manage, User
      cannot :manage, :reports
      cannot :manage, :settings
      cannot :manage, :cash_registers
      cannot :manage, PaymentMethod
      cannot :manage, :suppliers
      cannot :manage, :ingredients
      cannot :manage, :units
      cannot :manage, :currencies
      cannot :manage, :expenses
      cannot :manage, :purchases
      cannot :manage, :stocks
      cannot :manage, :combos
      cannot :manage, :recipes
      cannot :manage, :simple_products
      cannot [ :open, :close ], CashRegister
    end

    # Delivery: puede ver solo sus órdenes asignadas
    if user.has_role?(:delivery)
      can :read, :delivery
      can :read, Order, delivery_user_id: user.id
      can :read, Customer
      cannot :create, Order
      cannot :destroy, Order
      cannot :access, :admin_panel
      cannot :manage, User
      cannot :manage, :reports
      cannot :manage, :settings
      cannot :manage, :cash_registers
      cannot :manage, :products
      cannot :manage, :pos
      cannot :manage, :suppliers
      cannot :manage, :ingredients
      cannot :manage, :units
      cannot :manage, :currencies
      cannot :manage, :expenses
      cannot :manage, :purchases
      cannot :manage, :stocks
      cannot :manage, :combos
      cannot :manage, :recipes
      cannot :manage, :simple_products
    end
  end
end
