class AddVatRateToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :vat_rate, :integer
  end
end
