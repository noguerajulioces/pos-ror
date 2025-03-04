class AddPaymentMethodToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :payment_method, null: false, foreign_key: true
  end
end
