class AddTableIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :table, null: true, foreign_key: true
  end
end
