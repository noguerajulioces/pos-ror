class CreateOrderPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :order_payments do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :amount
      t.datetime :payment_date

      t.timestamps
    end
  end
end
