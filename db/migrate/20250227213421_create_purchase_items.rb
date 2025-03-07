class CreatePurchaseItems < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :purchase, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :unit_price
      t.decimal :total_price

      t.timestamps
    end
  end
end
