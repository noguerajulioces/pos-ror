# == Schema Information
#
# Table name: inventory_movements
#
#  id            :bigint           not null, primary key
#  movement_type :string
#  quantity      :integer
#  reason        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  product_id    :bigint           not null
#
# Indexes
#
#  index_inventory_movements_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class InventoryMovement < ApplicationRecord
  attr_accessor :skip_stock_update
  belongs_to :product

  # Define movement types
  enum :movement_type, {
    purchase: 'purchase',      # Compra de producto
    sale: 'sale',             # Venta de producto
    adjustment: 'adjustment',  # Ajuste manual
    return: 'return',         # Devolución
    transfer: 'transfer'      # Transferencia
  }

  # Validations
  validates :movement_type, :quantity, :product_id, presence: true
  validates :reason, presence: true, if: :adjustment?

  # Callbacks
  after_create :update_product_stock

  # Scopes
  scope :recent, -> { order(created_at: :desc).limit(30) }
  scope :incoming, -> { where('quantity > 0') }
  scope :outgoing, -> { where('quantity < 0') }

  def final_stock
    previous_movements = product.inventory_movements.where('created_at <= ?', created_at)
    previous_movements.sum(:quantity)
  end

  private

  def update_product_stock
    return if skip_stock_update

    current_stock = product.stock || 0
    new_stock = current_stock + quantity

    # First update the stock value
    product.update_columns(stock: new_stock)

    # Then update the status based on the new stock value
    update_product_status(new_stock)

    if purchase? && quantity.positive?
      product.update_average_cost(
        product.current_purchase_price,
        quantity
      )
    end
  end

  def update_product_status(new_stock)
    if new_stock <= 0
      product.update_columns(status: 'out_of_stock')
    elsif product.status != 'inactive'
      # Only change to active if it's not already set to inactive
      product.update_columns(status: 'active')
    end
  end
end
