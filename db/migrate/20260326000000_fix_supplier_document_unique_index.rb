class FixSupplierDocumentUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :suppliers, :document
    add_index :suppliers, [:account_id, :document], unique: true
  end
end
