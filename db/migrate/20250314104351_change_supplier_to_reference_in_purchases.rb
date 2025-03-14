class ChangeSupplierToReferenceInPurchases < ActiveRecord::Migration[8.0]
  def change
    remove_column :purchases, :supplier, :string
    add_reference :purchases, :supplier, foreign_key: true
  end
end
