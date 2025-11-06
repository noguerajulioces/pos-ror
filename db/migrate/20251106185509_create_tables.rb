class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables do |t|
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tables, :name
    add_index :tables, :active
  end
end
