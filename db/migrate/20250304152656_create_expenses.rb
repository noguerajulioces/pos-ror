class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.decimal :amount
      t.text :description
      t.date :expense_date
      t.references :purchase, null: false, foreign_key: true

      t.timestamps
    end
  end
end
