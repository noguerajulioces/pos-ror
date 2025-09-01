# frozen_string_literal: true

# Servicio para postear una compra y actualizar stock/costos
#
# Este servicio maneja la transacción completa de postear una compra:
# - Valida que la compra esté en estado draft
# - Bloquea la compra para evitar condiciones de carrera
# - Actualiza stock y costos promedio de productos e ingredientes
# - Cambia el estado a posted
#
# Nota: No se implementa reversión automática en cancelación
# para evitar complejidad. Se puede implementar en el futuro.
class Purchases::PostPurchase
  def self.call(purchase)
    new(purchase).call
  end

  def initialize(purchase)
    @purchase = purchase
  end

  def call
    ActiveRecord::Base.transaction do
      # Bloquear la compra para evitar condiciones de carrera
      @purchase.lock!

      # Validar que esté en estado draft
      raise StandardError, 'Solo se pueden postear compras en borrador' unless @purchase.draft?

      # Procesar cada item de la compra
      @purchase.purchase_items.each do |item|
        process_purchase_item(item)
      end

      # Actualizar estado de la compra
      @purchase.update!(
        status: 'posted',
        posted_at: Time.current
      )
    end
  rescue StandardError => e
    # Re-raise para que el controller maneje el error
    raise e
  end

  private

  def process_purchase_item(item)
    purchasable = item.purchasable

    case purchasable
    when Product
      process_product_item(item, purchasable)
    when Ingredient
      process_ingredient_item(item, purchasable)
    else
      raise StandardError, "Tipo de item no soportado: #{purchasable.class}"
    end
  end

  def process_product_item(item, product)
    # Solo permitir compra de productos simples
    unless product.purchasable?
      raise StandardError, "No se puede comprar el producto #{product.name} (tipo: #{product.kind})"
    end

    # Actualizar stock y costo promedio
    product.stock += item.quantity
    product.update_average_cost(item.unit_price, item.quantity)
  end

  def process_ingredient_item(item, ingredient)
    # Actualizar stock y costo promedio usando el método existente
    ingredient.add_stock(item.quantity, item.unit_price)
  end
end
