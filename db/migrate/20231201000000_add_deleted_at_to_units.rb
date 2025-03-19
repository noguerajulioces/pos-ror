class AddDeletedAtToUnits < ActiveRecord::Migration[8.0]
  def change
    add_column :units, :deleted_at, :datetime
    add_index :units, :deleted_at
  end
end