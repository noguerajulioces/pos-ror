Rails.application.routes.draw do
  root 'home#index'
  devise_for :users, skip: [ :registrations, :passwords ], path_names: { sign_in: 'login', sign_out: 'logout' }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  
  # Public PWA installation page
  get 'install' => 'install#index', as: :install

  # Defines the root path route ("/")
  # root "posts#index"
  resources :categories do
    resources :subcategories, only: [ :new, :create, :destroy ]
    member do
      get :subcategories, action: :subcategories_json, as: :subcategories_json
    end
  end
  resources :ingredients do
    collection do
      get :search
      post :check_name_uniqueness
    end
    member do
      get :unit
      get :adjust_stock_form
      post :adjust_stock
    end
  end

  # Ruta específica para el modal picker de ingredientes
  get 'ingredients/modal_picker/:product_id', to: 'ingredients#modal_picker', as: :ingredients_modal_picker

  # Productos simples - DEBE IR ANTES que la ruta general de products
  resources :simple_products, path: 'products/simple', as: :simple_products do
    resources :images, only: [ :destroy ], controller: 'product_images'
    resources :stock_transfers, only: [ :create ], controller: 'stock_transfers' do
      collection do
        get :transfer_form
        get :products_by_account
      end
    end
    member do
      patch :update_status
      get :adjust_stock_form
      post :adjust_stock
    end
  end

  # Recetas - DEBE IR ANTES que la ruta general de products
  resources :recipes, path: 'products/recipes' do
    resources :images, only: [ :destroy ], controller: 'product_images'
    member do
      patch :update_status
    end
  end

  resources :products, only: [ :show, :edit, :update ] do
    resources :product_images, only: [ :destroy ]
    resources :stock_adjustments, only: [ :new, :create ], module: 'products'
    namespace :products do
      resources :recipe_components, only: [ :create, :destroy ]
    end
    collection do
      get :search
      get :hub
    end
    member do
      get :unit
    end
  end

  resources :combos do
    member do
      patch :toggle_status
    end
  end
  resources :stocks, only: [ :index ]
  resources :units, except: %i[show]
  resources :customers do
    collection do
      get :search
      post :create_form
    end
  end
  resources :suppliers
  resources :users do
    member do
      patch :activate
      patch :deactivate
    end
  end
  resources :roles
  resources :delivery, only: [ :index ]
  resources :expenses, except: [ :show ]
  resources :currencies do
    member do
      patch :toggle_display
    end
  end
  resource :pos, only: [ :show ]
  patch 'pos/update_order_type', to: 'pos#update_order_type'
  get 'pos/subcategories', to: 'pos#subcategories'
  get 'pos/products_by_subcategory', to: 'pos#products_by_subcategory'
  get 'pos/products_by_category', to: 'pos#products_by_category'

  post 'pos/add_product_to_order', to: 'pos#add_product_to_order'
  post 'pos/set_order_type', to: 'pos#set_order_type'
  post 'pos/set_table', to: 'pos#set_table'
  post 'pos/update_order_type_and_table', to: 'pos#update_order_type_and_table'
  get 'pos/search_products', to: 'pos#search_products'

  resources :cash_registers, only: [ :index, :new, :create, :show ] do
    member do
      get :close
      patch :process_close
    end
  end
  get 'pos', to: 'pos#show'
  namespace :pos do
    resources :customers, only: [ :create ]
    namespace :modals do
      get 'order_type', to: 'order_types#show'
      get 'customer_search', to: 'customers#search'
      get 'orders', to: 'orders#index'
      get 'cash_register', to: 'cash_registers#show'
      get 'payment', to: 'payments#show'
      get 'item_discounts', to: 'item_discounts#show'
      get 'discounts', to: 'discounts#show'
      get 'deliveries', to: 'deliveries#show'
      get 'tables', to: 'tables#show'
    end

    post 'add_product_to_cart', to: 'carts#add_product_to_cart'
    delete 'remove_from_cart', to: 'carts#remove_from_cart'
    post 'clear_cart', to: 'carts#clear_cart'
    patch 'update_quantity', to: 'carts#update_quantity'
    post 'set_customer', to: 'carts#set_customer'
    post 'assign_delivery', to: 'carts#assign_delivery'
  end

  post 'pos/apply_discount', to: 'pos#apply_discount'
  post 'pos/create_order', to: 'pos#create_order'
  get  'pos/pending_kitchen_items', to: 'pos#pending_kitchen_items', as: 'pos_pending_kitchen_items'
  post 'pos/reload_cart', to: 'pos#reload_cart', as: 'pos_reload_cart'
  post 'pos/print_kitchen', to: 'pos#print_kitchen', as: 'pos_print_kitchen'
  get  'pos/kitchen_ticket', to: 'pos#kitchen_ticket', as: 'pos_kitchen_ticket'
  post 'pos/change_discount_type', to: 'pos#change_discount_type'
  post 'pos/save_order_notes', to: 'pos#save_order_notes'
  post 'pos/load_order_to_cart/:id', to: 'pos#load_order_to_cart', as: 'load_order_to_cart_pos'
  resources :payment_methods
  resources :tables
  resources :orders do
    member do
      get :print_preview
      get :receipt_preview
      patch :assign_delivery_user
    end
  end
  resources :pending_orders, only: [:index]
  resources :order_payments, except: [ :edit, :update ]

  post 'pos/process_payment', to: 'pos#process_payment', as: :process_payment_pos
  get 'print_message', to: 'print#print_message'
  resources :ingredients
  resources :purchases do
    member do
      post :post
      post :cancel
    end
  end
  resource :settings, only: [ :edit ] do
    patch :update_all, on: :collection
    get :printer, on: :collection
    patch :update_printer, on: :collection
    post :test_printer, on: :collection
  end
  resources :reports, only: [ :index ] do
    collection do
      get :products
      get :orders
      get :stocks
      get :expenses
      get :income_expenses
      get :credits
    end
  end

end
