class ConvertInventoryMovementsToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Remover el foreign key existente si existe
    if foreign_key_exists?(:inventory_movements, :products)
      remove_foreign_key :inventory_movements, :products
    end

    # Renombrar product_id a item_id
    rename_column :inventory_movements, :product_id, :item_id

    # Agregar columna item_type
    add_column :inventory_movements, :item_type, :string

    # Actualizar registros existentes para que apunten a Product
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE inventory_movements
          SET item_type = 'Product'
          WHERE item_type IS NULL
        SQL
      end
    end

    # Hacer item_type NOT NULL después de actualizar los datos
    change_column_null :inventory_movements, :item_type, false
    change_column_null :inventory_movements, :item_id, false

    # Agregar índice compuesto para la relación polimórfica
    add_index :inventory_movements, [:item_type, :item_id]
  end

  def down
    # Remover índice polimórfico
    remove_index :inventory_movements, [:item_type, :item_id]

    # Eliminar movimientos que no sean de productos
    execute "DELETE FROM inventory_movements WHERE item_type != 'Product'"

    # Eliminar columna item_type
    remove_column :inventory_movements, :item_type

    # Renombrar item_id de vuelta a product_id
    rename_column :inventory_movements, :item_id, :product_id

    # Restaurar foreign key
    add_foreign_key :inventory_movements, :products
  end
end
