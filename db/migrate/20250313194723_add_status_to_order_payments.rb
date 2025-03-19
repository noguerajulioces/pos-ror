class AddStatusToOrderPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :order_payments, :status, :string
  end
end
