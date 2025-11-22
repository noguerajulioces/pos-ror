# == Schema Information
#
# Table name: inventory_movements
#
#  id            :bigint           not null, primary key
#  item_type     :string           not null
#  movement_type :string
#  quantity      :decimal(10, 3)
#  reason        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  item_id       :bigint           not null
#
# Indexes
#
#  index_inventory_movements_on_account_id             (account_id)
#  index_inventory_movements_on_item_id                (item_id)
#  index_inventory_movements_on_item_type_and_item_id  (item_type,item_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class InventoryMovement < ApplicationRecord
  acts_as_tenant(:account)

  attr_accessor :skip_stock_update
  belongs_to :item, polymorphic: true

  # Define movement types
  enum :movement_type, {
    purchase: 'purchase',      # Compra de producto
    sale: 'sale',             # Venta de producto
    adjustment: 'adjustment',  # Ajuste manual
    return: 'return',         # Devolución
    transfer: 'transfer'      # Transferencia
  }

  # Validations
  validates :movement_type, :quantity, :item_id, :item_type, presence: true
  validates :reason, presence: true, if: :adjustment?

  # Callbacks
  after_create :update_product_stock

  # Scopes
  scope :recent, -> { order(created_at: :desc).limit(30) }
  scope :incoming, -> { where('quantity > 0') }
  scope :outgoing, -> { where('quantity < 0') }

  def final_stock
    previous_movements = item.inventory_movements.where('created_at <= ?', created_at)
    previous_movements.sum(:quantity)
  end

  private

  def update_product_stock
    return if skip_stock_update

    # No actualizar stock físico para productos recipe o combo
    # Estos tipos no manejan stock físico
    if item_type == 'Product' && item.kind.in?([ 'recipe', 'combo' ])
      return
    end

    # For purchases, use update_average_cost which handles both stock and cost
    if purchase? && quantity.positive?
      # Obtener el precio de compra dependiendo del tipo
      purchase_price = if item_type == 'Product'
                         item.current_purchase_price
                       else
                         item.average_cost || 0
                       end

      item.update_average_cost(purchase_price, quantity)
      # Stock is now updated, get the new value for status update
      new_stock = item.stock
    else
      # For non-purchase movements, manually update stock
      current_stock = item.stock || 0
      new_stock = current_stock + quantity
      item.update_columns(stock: new_stock)
    end

    # Update status based on the new stock value (only for products)
    update_item_status(new_stock) if item_type == 'Product'
  end

  def update_item_status(new_stock)
    if new_stock <= 0
      item.update_columns(status: 'out_of_stock')
    elsif item.status != 'inactive'
      # Only change to active if it's not already set to inactive
      item.update_columns(status: 'active')
    end
  end
end
