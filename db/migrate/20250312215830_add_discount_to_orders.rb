class AddDiscountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :discount_percentage, :decimal, precision: 5, scale: 2
    add_column :orders, :discount_reason, :string
  end
end
