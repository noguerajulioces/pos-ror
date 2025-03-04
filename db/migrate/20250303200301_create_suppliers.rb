class CreateSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers do |t|
      t.string :company_name
      t.string :document
      t.string :contact_name
      t.string :email
      t.string :phone
      t.string :address
      t.text   :notes

      t.timestamps
    end

    add_index :suppliers, :document, unique: true
  end
end
