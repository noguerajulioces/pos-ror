class AddKitchenPrintedQuantityToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :kitchen_printed_quantity, :decimal, precision: 10, scale: 3, default: 0, null: false
  end
end
