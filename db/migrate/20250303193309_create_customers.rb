class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.text   :notes

      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
