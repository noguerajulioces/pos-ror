class ChangeQuantityTypeInOrderItems < ActiveRecord::Migration[8.0]
  def change
    change_column :order_items, :quantity, :decimal, precision: 10, scale: 3
  end
end