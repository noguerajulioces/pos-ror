class AddStatusFieldsToPurchases < ActiveRecord::Migration[8.0]
  def change
    add_column :purchases, :status, :string, default: 'draft'
    add_column :purchases, :posted_at, :datetime
    add_column :purchases, :invoice_number, :string
    add_column :purchases, :payment_method, :string
    add_column :purchases, :notes, :text

    add_index :purchases, :status
    add_index :purchases, :posted_at
  end
end
