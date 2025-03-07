class CreateCashRegisters < ActiveRecord::Migration[8.0]
  def change
    create_table :cash_registers do |t|
      t.datetime :open_at
      t.datetime :close_at
      t.decimal :initial_amount
      t.decimal :final_amount
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
