class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.decimal :total_amount
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
