class AddPaymentMethodToOrderPayments < ActiveRecord::Migration[7.0]
  def change
    add_reference :order_payments, :payment_method, null: false, foreign_key: true
    add_column :order_payments, :reference_number, :string
    add_column :order_payments, :notes, :text
  end
end
