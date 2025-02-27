class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.string :supplier
      t.date :purchase_date
      t.decimal :total_amount

      t.timestamps
    end
  end
end
