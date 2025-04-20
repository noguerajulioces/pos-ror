class RenamePriceToPriceBaseInProducts < ActiveRecord::Migration[8.0]
  def change
    rename_column :products, :price, :price_base
  end
end
