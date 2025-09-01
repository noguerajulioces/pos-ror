class CreateJoinProductsModifierGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :modifier_groups_products do |t|
      t.references :product, null: false, foreign_key: true
      t.references :modifier_group, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :modifier_groups_products, :deleted_at
    add_index :modifier_groups_products, [ :product_id, :modifier_group_id ], unique: true, name: 'index_modifier_groups_products_unique'
  end
end
