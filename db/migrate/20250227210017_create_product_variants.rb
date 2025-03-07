class CreateProductVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :product_variants do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :stock
      t.string :sku
      t.string :barcode
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
