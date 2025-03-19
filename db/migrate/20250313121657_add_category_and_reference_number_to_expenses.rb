class AddCategoryAndReferenceNumberToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :expenses, :category, :string
    add_column :expenses, :reference_number, :string

    add_index :expenses, :category
    add_index :expenses, :reference_number, unique: true
  end
end
