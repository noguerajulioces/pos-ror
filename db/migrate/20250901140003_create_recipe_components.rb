class CreateRecipeComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_components do |t|
      t.references :product, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      t.decimal :quantity, precision: 12, scale: 3, null: false
      t.decimal :waste_pct, precision: 5, scale: 2, default: 0
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :recipe_components, :deleted_at
    add_index :recipe_components, [ :product_id, :ingredient_id ], unique: true
  end
end
