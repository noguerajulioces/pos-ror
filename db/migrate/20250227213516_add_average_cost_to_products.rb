class AddAverageCostToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :average_cost, :decimal
  end
end
