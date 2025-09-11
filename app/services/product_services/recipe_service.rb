# frozen_string_literal: true

module ProductServices
  # Service para manejar la lógica de recetas y stock de ingredientes
  # Centraliza validaciones y operaciones de stock para productos tipo receta
  class RecipeService
    attr_reader :product

    def initialize(product)
      @product = product
    end

    # Valida si hay suficiente stock para producir una cantidad específica
    def validate_stock_availability(quantity_to_produce = 1)
      result = {
        sufficient: true,
        missing_ingredients: [],
        warnings: []
      }

      product.recipe_components.includes(:ingredient, :unit).each do |component|
        needed_quantity = component.total_quantity_with_waste * quantity_to_produce
        available_stock = component.ingredient.stock

        if available_stock < needed_quantity
          result[:sufficient] = false
          result[:missing_ingredients] << {
            ingredient: component.ingredient.name,
            needed: needed_quantity,
            available: available_stock,
            missing: needed_quantity - available_stock,
            unit: component.unit.abbreviation
          }
        elsif available_stock < (needed_quantity * 2) # Warning if less than 2x needed
          result[:warnings] << {
            ingredient: component.ingredient.name,
            available: available_stock,
            unit: component.unit.abbreviation,
            message: 'Stock bajo para futuras producciones'
          }
        end
      end

      result
    end

    # Deduce el stock de ingredientes al producir el producto
    def deduct_ingredients_stock(quantity_produced = 1)
      return false unless validate_stock_availability(quantity_produced)[:sufficient]

      deduction_results = []

      ActiveRecord::Base.transaction do
        product.recipe_components.includes(:ingredient).each do |component|
          needed_quantity = component.total_quantity_with_waste * quantity_produced

          if component.ingredient.deduct_stock(needed_quantity)
            deduction_results << {
              ingredient: component.ingredient.name,
              deducted: needed_quantity,
              remaining_stock: component.ingredient.reload.stock,
              unit: component.unit.abbreviation
            }
          else
            raise ActiveRecord::Rollback, "Failed to deduct stock for #{component.ingredient.name}"
          end
        end
      end

      {
        success: deduction_results.any?,
        deductions: deduction_results
      }
    end

    # Calcula el costo total de la receta
    def calculate_recipe_cost(quantity = 1)
      total_cost = 0

      product.recipe_components.includes(:ingredient).each do |component|
        ingredient_cost = component.ingredient.average_cost || 0
        needed_quantity = component.total_quantity_with_waste * quantity
        total_cost += ingredient_cost * needed_quantity
      end

      total_cost.round(2)
    end

    # Obtiene un resumen completo de la receta
    def recipe_summary
      components_info = product.recipe_components.includes(:ingredient, :unit).map do |component|
        {
          ingredient: component.ingredient.name,
          quantity: component.quantity,
          waste_pct: component.waste_pct,
          total_with_waste: component.total_quantity_with_waste,
          unit: component.unit.name,
          unit_abbreviation: component.unit.abbreviation,
          stock_available: component.ingredient.stock,
          cost_per_unit: component.ingredient.average_cost || 0,
          total_cost: (component.ingredient.average_cost || 0) * component.total_quantity_with_waste,
          stock_status: component.ingredient.stock_status
        }
      end

      {
        total_components: components_info.count,
        total_cost: calculate_recipe_cost,
        components: components_info,
        can_produce: validate_stock_availability[:sufficient],
        max_producible: calculate_max_producible_quantity
      }
    end

    # Calcula cuántas unidades del producto se pueden producir con el stock actual
    def calculate_max_producible_quantity
      return 0 if product.recipe_components.empty?

      min_possible = Float::INFINITY

      product.recipe_components.includes(:ingredient).each do |component|
        needed_per_unit = component.total_quantity_with_waste
        available_stock = component.ingredient.stock

        possible_from_this_ingredient = (available_stock / needed_per_unit).floor
        min_possible = [ min_possible, possible_from_this_ingredient ].min
      end

      min_possible == Float::INFINITY ? 0 : min_possible
    end

    # Verifica ingredientes con stock crítico para esta receta
    def check_critical_ingredients
      critical_ingredients = []

      product.recipe_components.includes(:ingredient).each do |component|
        ingredient = component.ingredient
        needed_for_one_unit = component.total_quantity_with_waste

        # Crítico si el stock actual es menos de 5 veces lo necesario para una unidad
        if ingredient.stock < (needed_for_one_unit * 5)
          critical_ingredients << {
            name: ingredient.name,
            current_stock: ingredient.stock,
            needed_per_unit: needed_for_one_unit,
            unit: component.unit.abbreviation,
            days_remaining: calculate_days_remaining(ingredient, needed_for_one_unit)
          }
        end
      end

      critical_ingredients
    end

    private

    def calculate_days_remaining(ingredient, needed_per_unit)
      return 0 if needed_per_unit <= 0

      # Asumiendo producción promedio diaria (esto podría ser más sofisticado)
      daily_production = 10 # Valor por defecto, podría venir de configuración
      daily_consumption = needed_per_unit * daily_production

      return 0 if daily_consumption <= 0

      (ingredient.stock / daily_consumption).round(1)
    end
  end
end
