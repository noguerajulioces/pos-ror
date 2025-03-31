class ChangeQuantityTypeInInventoryMovements < ActiveRecord::Migration[8.0]
  def change
    change_column :inventory_movements, :quantity, :decimal, precision: 10, scale: 3
  end
end
