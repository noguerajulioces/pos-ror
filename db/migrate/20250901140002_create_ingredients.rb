class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :sku
      t.references :unit, null: false, foreign_key: true
      t.decimal :stock, precision: 12, scale: 3, default: 0
      t.decimal :min_stock, precision: 12, scale: 3, default: 0
      t.decimal :average_cost, precision: 12, scale: 2, default: 0
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :ingredients, :deleted_at
    add_index :ingredients, :sku
    add_index :ingredients, :name
  end
end
