class CreateStockTransfers < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_transfers do |t|
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }

      t.string :from_item_type, null: false
      t.bigint :from_item_id, null: false
      t.string :to_item_type, null: false
      t.bigint :to_item_id, null: false

      t.decimal :quantity, precision: 10, scale: 3, null: false
      t.string :reason
      t.string :status, null: false, default: 'pending'

      t.references :transferred_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :stock_transfers, [:from_item_type, :from_item_id]
    add_index :stock_transfers, [:to_item_type, :to_item_id]
    add_index :stock_transfers, :status
  end
end
