class AddAccountToTenantModels < ActiveRecord::Migration[8.0]
  def change
    tables = %i[
      products product_variants product_images
      categories customers suppliers
      sales sale_items purchases purchase_items
      expenses inventory_movements
      orders order_items order_payments
      cash_registers cash_movements
      currencies payment_methods
      settings units
    ]

    tables.each do |table|
      add_reference table, :account, null: false, foreign_key: true
    end
  end
end
