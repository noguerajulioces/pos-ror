# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_20_203255) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cash_movements", force: :cascade do |t|
    t.bigint "cash_register_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "movement_type", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_cash_movements_on_account_id"
    t.index ["cash_register_id"], name: "index_cash_movements_on_cash_register_id"
  end

  create_table "cash_registers", force: :cascade do |t|
    t.datetime "open_at"
    t.datetime "close_at"
    t.decimal "initial_amount"
    t.decimal "final_amount"
    t.string "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_cash_registers_on_account_id"
    t.index ["user_id"], name: "index_cash_registers_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "combo_items", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "component_product_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "1.0", null: false
    t.boolean "optional", default: false
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "choice_group_id"
    t.index ["account_id"], name: "index_combo_items_on_account_id"
    t.index ["choice_group_id"], name: "index_combo_items_on_choice_group_id"
    t.index ["component_product_id"], name: "index_combo_items_on_component_product_id"
    t.index ["deleted_at"], name: "index_combo_items_on_deleted_at"
    t.index ["product_id", "component_product_id"], name: "index_combo_items_on_product_id_and_component_product_id", unique: true
    t.index ["product_id"], name: "index_combo_items_on_product_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "symbol"
    t.decimal "exchange_rate"
    t.string "flag_url"
    t.boolean "display"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_currencies_on_account_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document"
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_customers_on_account_id"
    t.index ["email"], name: "index_customers_on_email", unique: true
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount"
    t.text "description"
    t.date "expense_date"
    t.bigint "purchase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "payment_method_id"
    t.string "category"
    t.string "reference_number"
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_expenses_on_account_id"
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["payment_method_id"], name: "index_expenses_on_payment_method_id"
    t.index ["purchase_id"], name: "index_expenses_on_purchase_id"
    t.index ["reference_number"], name: "index_expenses_on_reference_number"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.string "sku"
    t.bigint "unit_id", null: false
    t.decimal "stock", precision: 12, scale: 3, default: "0.0"
    t.decimal "min_stock", precision: 12, scale: 3, default: "0.0"
    t.decimal "average_cost", precision: 12, scale: 2, default: "0.0"
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ingredients_on_account_id"
    t.index ["deleted_at"], name: "index_ingredients_on_deleted_at"
    t.index ["name"], name: "index_ingredients_on_name"
    t.index ["sku"], name: "index_ingredients_on_sku"
    t.index ["unit_id"], name: "index_ingredients_on_unit_id"
  end

  create_table "inventory_movements", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.decimal "quantity", precision: 10, scale: 3
    t.string "movement_type"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.string "item_type", null: false
    t.index ["account_id"], name: "index_inventory_movements_on_account_id"
    t.index ["item_id"], name: "index_inventory_movements_on_item_id"
    t.index ["item_type", "item_id"], name: "index_inventory_movements_on_item_type_and_item_id"
  end

  create_table "modifier_groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "min_select", default: 0
    t.integer "max_select", default: 1
    t.boolean "required", default: false
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_modifier_groups_on_account_id"
    t.index ["deleted_at"], name: "index_modifier_groups_on_deleted_at"
  end

  create_table "modifier_groups_products", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "modifier_group_id", null: false
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_modifier_groups_products_on_account_id"
    t.index ["deleted_at"], name: "index_modifier_groups_products_on_deleted_at"
    t.index ["modifier_group_id"], name: "index_modifier_groups_products_on_modifier_group_id"
    t.index ["product_id", "modifier_group_id"], name: "index_modifier_groups_products_unique", unique: true
    t.index ["product_id"], name: "index_modifier_groups_products_on_product_id"
  end

  create_table "modifiers", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price_delta", precision: 12, scale: 2, default: "0.0"
    t.string "sku"
    t.bigint "modifier_group_id", null: false
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_modifiers_on_account_id"
    t.index ["deleted_at"], name: "index_modifiers_on_deleted_at"
    t.index ["modifier_group_id"], name: "index_modifiers_on_modifier_group_id"
    t.index ["sku"], name: "index_modifiers_on_sku"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity", precision: 10, scale: 3
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "subtotal", precision: 10, scale: 2
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_order_items_on_account_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "order_payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.decimal "amount"
    t.datetime "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "payment_method_id", null: false
    t.string "reference_number"
    t.text "notes"
    t.string "status"
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_order_payments_on_account_id"
    t.index ["order_id"], name: "index_order_payments_on_order_id"
    t.index ["payment_method_id"], name: "index_order_payments_on_payment_method_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "order_date"
    t.decimal "total_amount"
    t.string "status"
    t.bigint "user_id", null: false
    t.bigint "payment_method_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_id"
    t.string "order_type"
    t.decimal "discount_percentage", precision: 5, scale: 2
    t.string "discount_reason"
    t.string "receipt_number"
    t.bigint "account_id", null: false
    t.bigint "delivery_user_id"
    t.decimal "delivery_amount", precision: 12, scale: 2, default: "0.0"
    t.text "notes"
    t.bigint "table_id"
    t.index ["account_id"], name: "index_orders_on_account_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["delivery_user_id"], name: "index_orders_on_delivery_user_id"
    t.index ["payment_method_id"], name: "index_orders_on_payment_method_id"
    t.index ["table_id"], name: "index_orders_on_table_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_payment_methods_on_account_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "alt_text"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_product_images_on_account_id"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.integer "stock"
    t.string "sku"
    t.string "barcode"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_product_variants_on_account_id"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 12, scale: 2
    t.string "barcode"
    t.string "sku"
    t.decimal "stock", precision: 12, scale: 3
    t.decimal "min_stock", precision: 12, scale: 3
    t.string "status"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "average_cost", precision: 12, scale: 2
    t.bigint "unit_id"
    t.string "slug"
    t.datetime "deleted_at"
    t.decimal "manual_purchase_price", precision: 12, scale: 2
    t.bigint "account_id", null: false
    t.string "kind", default: "simple"
    t.string "kitchen_station"
    t.string "print_name"
    t.string "menu_section"
    t.integer "prep_time_seconds", default: 0
    t.integer "sort_order", default: 0
    t.string "availability_channels", default: [], array: true
    t.boolean "is_featured", default: false
    t.boolean "is_vegan", default: false
    t.boolean "is_vegetarian", default: false
    t.boolean "is_gluten_free", default: false
    t.bigint "tax_rate_id"
    t.index ["account_id"], name: "index_products_on_account_id"
    t.index ["availability_channels"], name: "index_products_on_availability_channels", using: :gin
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
    t.index ["kind"], name: "index_products_on_kind"
    t.index ["kitchen_station"], name: "index_products_on_kitchen_station"
    t.index ["menu_section"], name: "index_products_on_menu_section"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["sort_order"], name: "index_products_on_sort_order"
    t.index ["tax_rate_id"], name: "index_products_on_tax_rate_id"
    t.index ["unit_id"], name: "index_products_on_unit_id"
  end

  create_table "purchase_items", force: :cascade do |t|
    t.bigint "purchase_id", null: false
    t.decimal "quantity", precision: 12, scale: 3
    t.decimal "unit_price", precision: 12, scale: 2
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.string "purchasable_type"
    t.bigint "purchasable_id"
    t.bigint "unit_id"
    t.decimal "subtotal", precision: 12, scale: 2
    t.index ["account_id"], name: "index_purchase_items_on_account_id"
    t.index ["purchasable_type", "purchasable_id"], name: "index_purchase_items_on_purchasable_type_and_purchasable_id"
    t.index ["purchase_id"], name: "index_purchase_items_on_purchase_id"
    t.index ["unit_id"], name: "index_purchase_items_on_unit_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.date "purchase_date"
    t.decimal "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "supplier_id"
    t.bigint "account_id", null: false
    t.string "status", default: "draft"
    t.datetime "posted_at"
    t.string "invoice_number"
    t.string "payment_method"
    t.text "notes"
    t.index ["account_id"], name: "index_purchases_on_account_id"
    t.index ["posted_at"], name: "index_purchases_on_posted_at"
    t.index ["status"], name: "index_purchases_on_status"
    t.index ["supplier_id"], name: "index_purchases_on_supplier_id"
  end

  create_table "recipe_components", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "ingredient_id", null: false
    t.bigint "unit_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.decimal "waste_pct", precision: 5, scale: 2, default: "0.0"
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_recipe_components_on_account_id"
    t.index ["deleted_at"], name: "index_recipe_components_on_deleted_at"
    t.index ["ingredient_id"], name: "index_recipe_components_on_ingredient_id"
    t.index ["product_id", "ingredient_id"], name: "index_recipe_components_on_product_id_and_ingredient_id", unique: true
    t.index ["product_id"], name: "index_recipe_components_on_product_id"
    t.index ["unit_id"], name: "index_recipe_components_on_unit_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "sale_items", force: :cascade do |t|
    t.bigint "sale_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.decimal "price"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_sale_items_on_account_id"
    t.index ["product_id"], name: "index_sale_items_on_product_id"
    t.index ["sale_id"], name: "index_sale_items_on_sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.decimal "total_amount"
    t.string "payment_method"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_sales_on_account_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_settings_on_account_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "company_name"
    t.string "document"
    t.string "contact_name"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_suppliers_on_account_id"
    t.index ["document"], name: "index_suppliers_on_document", unique: true
  end

  create_table "tables", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tables_on_account_id"
    t.index ["active"], name: "index_tables_on_active"
    t.index ["name"], name: "index_tables_on_name"
  end

  create_table "tax_rates", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.boolean "is_active", default: true
    t.bigint "account_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tax_rates_on_account_id"
    t.index ["deleted_at"], name: "index_tax_rates_on_deleted_at"
    t.index ["is_active"], name: "index_tax_rates_on_is_active"
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_units_on_account_id"
    t.index ["deleted_at"], name: "index_units_on_deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.boolean "super_user", default: false, null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cash_movements", "accounts"
  add_foreign_key "cash_movements", "cash_registers"
  add_foreign_key "cash_registers", "accounts"
  add_foreign_key "cash_registers", "users"
  add_foreign_key "categories", "accounts"
  add_foreign_key "combo_items", "accounts"
  add_foreign_key "combo_items", "modifier_groups", column: "choice_group_id"
  add_foreign_key "combo_items", "products"
  add_foreign_key "combo_items", "products", column: "component_product_id"
  add_foreign_key "currencies", "accounts"
  add_foreign_key "customers", "accounts"
  add_foreign_key "expenses", "accounts"
  add_foreign_key "expenses", "payment_methods"
  add_foreign_key "expenses", "purchases"
  add_foreign_key "ingredients", "accounts"
  add_foreign_key "ingredients", "units"
  add_foreign_key "inventory_movements", "accounts"
  add_foreign_key "modifier_groups", "accounts"
  add_foreign_key "modifier_groups_products", "accounts"
  add_foreign_key "modifier_groups_products", "modifier_groups"
  add_foreign_key "modifier_groups_products", "products"
  add_foreign_key "modifiers", "accounts"
  add_foreign_key "modifiers", "modifier_groups"
  add_foreign_key "order_items", "accounts"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_payments", "accounts"
  add_foreign_key "order_payments", "orders"
  add_foreign_key "order_payments", "payment_methods"
  add_foreign_key "orders", "accounts"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "payment_methods"
  add_foreign_key "orders", "tables"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "users", column: "delivery_user_id"
  add_foreign_key "payment_methods", "accounts"
  add_foreign_key "product_images", "accounts"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_variants", "accounts"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "accounts"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "tax_rates"
  add_foreign_key "products", "units"
  add_foreign_key "purchase_items", "accounts"
  add_foreign_key "purchase_items", "purchases"
  add_foreign_key "purchase_items", "units"
  add_foreign_key "purchases", "accounts"
  add_foreign_key "purchases", "suppliers"
  add_foreign_key "recipe_components", "accounts"
  add_foreign_key "recipe_components", "ingredients"
  add_foreign_key "recipe_components", "products"
  add_foreign_key "recipe_components", "units"
  add_foreign_key "sale_items", "accounts"
  add_foreign_key "sale_items", "products"
  add_foreign_key "sale_items", "sales"
  add_foreign_key "sales", "accounts"
  add_foreign_key "settings", "accounts"
  add_foreign_key "suppliers", "accounts"
  add_foreign_key "tables", "accounts"
  add_foreign_key "tax_rates", "accounts"
  add_foreign_key "units", "accounts"
  add_foreign_key "users", "accounts"
end
