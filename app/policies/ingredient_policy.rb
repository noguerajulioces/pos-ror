class IngredientPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.present?
  end

  def search?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
