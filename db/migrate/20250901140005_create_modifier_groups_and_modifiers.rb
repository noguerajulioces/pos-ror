class CreateModifierGroupsAndModifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :modifier_groups do |t|
      t.string :name, null: false
      t.integer :min_select, default: 0
      t.integer :max_select, default: 1
      t.boolean :required, default: false
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    create_table :modifiers do |t|
      t.string :name, null: false
      t.decimal :price_delta, precision: 12, scale: 2, default: 0
      t.string :sku
      t.references :modifier_group, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :modifier_groups, :deleted_at
    add_index :modifiers, :deleted_at
    add_index :modifiers, :sku
  end
end
