class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :barcode
      t.string :sku
      t.integer :stock
      t.integer :min_stock
      t.string :status
      t.references :category, null: false, foreign_key: { to_table: :categories }

      t.timestamps
    end
  end
end
