class ChangePurchaseItemsToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Agregar columnas polimórficas
    add_column :purchase_items, :purchasable_type, :string
    add_column :purchase_items, :purchasable_id, :bigint
    add_column :purchase_items, :unit_id, :bigint
    add_column :purchase_items, :subtotal, :decimal, precision: 12, scale: 2

    # Cambiar precision de columnas existentes
    change_column :purchase_items, :quantity, :decimal, precision: 12, scale: 3
    change_column :purchase_items, :unit_price, :decimal, precision: 12, scale: 2

    # Backfill: setear purchasable_type y purchasable_id para registros existentes
    execute <<-SQL
      UPDATE purchase_items#{' '}
      SET purchasable_type = 'Product',#{' '}
          purchasable_id = product_id,
          subtotal = COALESCE(quantity, 0) * COALESCE(unit_price, 0)
      WHERE product_id IS NOT NULL
    SQL

    # Agregar índices
    add_index :purchase_items, [ :purchasable_type, :purchasable_id ]
    add_index :purchase_items, :unit_id

    # Agregar foreign key para unit_id
    add_foreign_key :purchase_items, :units

    # Eliminar foreign key y columna product_id
    remove_foreign_key :purchase_items, :products if foreign_key_exists?(:purchase_items, :products)
    remove_column :purchase_items, :product_id
  end

  def down
    # Recrear columna product_id
    add_column :purchase_items, :product_id, :bigint

    # Backfill inverso: restaurar product_id para registros de Product
    execute <<-SQL
      UPDATE purchase_items#{' '}
      SET product_id = purchasable_id
      WHERE purchasable_type = 'Product'
    SQL

    # Agregar foreign key de vuelta
    add_foreign_key :purchase_items, :products

    # Eliminar columnas polimórficas
    remove_column :purchase_items, :purchasable_type
    remove_column :purchase_items, :purchasable_id
    remove_column :purchase_items, :unit_id
    remove_column :purchase_items, :subtotal

    # Restaurar precision original
    change_column :purchase_items, :quantity, :decimal, precision: 10, scale: 2
    change_column :purchase_items, :unit_price, :decimal, precision: 10, scale: 2

    # Eliminar índices
    remove_index :purchase_items, [ :purchasable_type, :purchasable_id ] if index_exists?(:purchase_items, [ :purchasable_type, :purchasable_id ])
    remove_index :purchase_items, :unit_id if index_exists?(:purchase_items, :unit_id)
  end
end
