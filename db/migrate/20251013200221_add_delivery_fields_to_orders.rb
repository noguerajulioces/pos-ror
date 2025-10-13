class AddDeliveryFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :delivery_user_id, :bigint
    add_column :orders, :delivery_amount, :decimal, precision: 12, scale: 2, default: 0
    add_foreign_key :orders, :users, column: :delivery_user_id
    add_index :orders, :delivery_user_id
  end
end
