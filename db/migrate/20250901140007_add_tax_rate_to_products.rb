class AddTaxRateToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :tax_rate, null: true, foreign_key: true
  end
end
