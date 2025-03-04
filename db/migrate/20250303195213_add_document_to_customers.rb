class AddDocumentToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :document, :string
  end
end
