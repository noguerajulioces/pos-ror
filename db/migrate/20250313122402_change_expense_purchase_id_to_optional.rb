class ChangeExpensePurchaseIdToOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :expenses, :purchase_id, true
    change_column_null :expenses, :payment_method_id, true
  end
end
