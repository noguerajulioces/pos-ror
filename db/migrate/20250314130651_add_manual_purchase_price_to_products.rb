class AddManualPurchasePriceToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :manual_purchase_price, :decimal
  end
end
