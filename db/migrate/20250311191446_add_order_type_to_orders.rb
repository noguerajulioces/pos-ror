class AddOrderTypeToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :order_type, :string
  end
end
