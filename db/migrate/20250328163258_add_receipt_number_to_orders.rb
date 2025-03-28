class AddReceiptNumberToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :receipt_number, :string
  end
end
