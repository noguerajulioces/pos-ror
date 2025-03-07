class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.string :alt_text
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
