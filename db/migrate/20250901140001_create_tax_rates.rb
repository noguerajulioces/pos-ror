class CreateTaxRates < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_rates do |t|
      t.string :name, null: false
      t.decimal :percentage, precision: 5, scale: 2, null: false
      t.boolean :is_active, default: true
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :tax_rates, :deleted_at
    add_index :tax_rates, :is_active
  end
end
