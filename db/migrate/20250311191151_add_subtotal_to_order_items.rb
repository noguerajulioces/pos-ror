class AddSubtotalToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :subtotal, :decimal, precision: 10, scale: 2
  end
end
