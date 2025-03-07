class AddUnitToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :unit, null: true, foreign_key: true
  end
end
