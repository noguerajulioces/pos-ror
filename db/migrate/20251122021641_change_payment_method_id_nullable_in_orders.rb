class ChangePaymentMethodIdNullableInOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :payment_method_id, true
  end
end
