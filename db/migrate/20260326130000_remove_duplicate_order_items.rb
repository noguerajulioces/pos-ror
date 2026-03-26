class RemoveDuplicateOrderItems < ActiveRecord::Migration[8.0]
  def up
    # For each order, keep only one order_item per product_id
    # Keep the one with the highest kitchen_printed_quantity (most "advanced" in kitchen workflow)
    execute <<~SQL
      DELETE FROM order_items
      WHERE id NOT IN (
        SELECT DISTINCT ON (order_id, product_id) id
        FROM order_items
        ORDER BY order_id, product_id, kitchen_printed_quantity DESC, id DESC
      )
    SQL
  end

  def down
    # Irreversible: duplicates cannot be restored
    raise ActiveRecord::IrreversibleMigration
  end
end
