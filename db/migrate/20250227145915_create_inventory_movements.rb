class CreateInventoryMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.string :movement_type
      t.string :reason

      t.timestamps
    end
  end
end
