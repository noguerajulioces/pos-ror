class ChangeStockColumnsToFloatInProducts < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :stock, :decimal, precision: 10, scale: 3
    change_column :products, :min_stock, :decimal, precision: 10, scale: 3
  end
end
