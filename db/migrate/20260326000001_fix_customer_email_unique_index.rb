class FixCustomerEmailUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :customers, :email
    add_index :customers, [:account_id, :email], unique: true
  end
end
