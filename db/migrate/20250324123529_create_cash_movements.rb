class CreateCashMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :cash_movements do |t|
      t.references :cash_register, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :movement_type, null: false
      t.string :reason

      t.timestamps
    end
  end
end
