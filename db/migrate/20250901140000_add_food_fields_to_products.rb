class AddFoodFieldsToProducts < ActiveRecord::Migration[8.0]
  def change
    # Enums para tipo de producto y estación de cocina
    add_column :products, :kind, :string, default: 'simple'
    add_column :products, :kitchen_station, :string

    # Campos operativos
    add_column :products, :print_name, :string
    add_column :products, :menu_section, :string
    add_column :products, :prep_time_seconds, :integer, default: 0
    add_column :products, :sort_order, :integer, default: 0
    add_column :products, :availability_channels, :string, array: true, default: []
    add_column :products, :is_featured, :boolean, default: false

    # Flags nutricionales
    add_column :products, :is_vegan, :boolean, default: false
    add_column :products, :is_vegetarian, :boolean, default: false
    add_column :products, :is_gluten_free, :boolean, default: false

    # Impuestos (se agregará en migración separada)
    # add_reference :products, :tax_rate, null: true, foreign_key: true

    # Ajustar precision/scale de campos existentes
    change_column :products, :price, :decimal, precision: 12, scale: 2
    change_column :products, :average_cost, :decimal, precision: 12, scale: 2
    change_column :products, :manual_purchase_price, :decimal, precision: 12, scale: 2
    change_column :products, :stock, :decimal, precision: 12, scale: 3
    change_column :products, :min_stock, :decimal, precision: 12, scale: 3

    # Índices para performance
    add_index :products, :kind
    add_index :products, :kitchen_station
    add_index :products, :menu_section
    add_index :products, :sort_order
    add_index :products, :availability_channels, using: :gin
  end
end
