# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role?(:superadmin)
      can :manage, :all
    end

    if user.has_role?(:vendedor)
      can [ :read, :create ], Order
      can :read, Product
      cannot :destroy, Order
    end

    if user.has_role?(:cajero)
      can :read, Order
      can [ :open, :close ], CashRegister
      can :read, Product
    end
  end
end
