class CreateComboItems < ActiveRecord::Migration[8.0]
  def change
    create_table :combo_items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :component_product, null: false, foreign_key: { to_table: :products }
      t.decimal :quantity, precision: 12, scale: 3, null: false, default: 1
      t.boolean :optional, default: false
      # t.references :choice_group, null: true, foreign_key: { to_table: :modifier_groups }
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :combo_items, :deleted_at
    add_index :combo_items, [ :product_id, :component_product_id ], unique: true
  end
end
