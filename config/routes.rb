Rails.application.routes.draw do
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end

  root 'pages#index'
  devise_for :users, skip: [ :registrations, :passwords ], path_names: { sign_in: 'login', sign_out: 'logout' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :categories do
    resources :subcategories, only: [ :new, :create ]
  end
  resources :products do
    resources :product_images, only: [ :destroy ]
    resources :stock_adjustments, only: [ :new, :create ], module: 'products'
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
  resources :users
  resources :expenses, except: [ :show ]
  resources :currencies
  resource :pos, only: [ :show ]
  patch 'pos/update_order_type', to: 'pos#update_order_type'
  get 'pos/subcategories', to: 'pos#subcategories'
  get 'pos/products_by_subcategory', to: 'pos#products_by_subcategory'

  post 'pos/add_product_to_order', to: 'pos#add_product_to_order'
  post 'pos/set_order_type', to: 'pos#set_order_type'
  get 'pos/search_products', to: 'pos#search_products'

  resources :cash_registers, only: [ :index, :new, :create ] do
    member do
      get :close
      patch :process_close
    end
  end
  get 'pos', to: 'pos#show'
  namespace :pos do
    namespace :modals do
      get 'order_type', to: 'order_types#show'
      get 'customer_search', to: 'customers#search'
      get 'orders', to: 'orders#index'
      get 'cash_register', to: 'cash_registers#show'
      get 'payment', to: 'payments#show'
      get 'item_discounts', to: 'item_discounts#show'
      get 'discounts', to: 'discounts#show'
    end

    post 'add_product_to_cart', to: 'carts#add_product_to_cart'
    delete 'remove_from_cart', to: 'carts#remove_from_cart'
    post 'clear_cart', to: 'carts#clear_cart'
    patch 'update_quantity', to: 'carts#update_quantity'
    post 'set_customer', to: 'carts#set_customer'
  end

  post 'pos/apply_discount', to: 'pos#apply_discount'
  post 'pos/create_order', to: 'pos#create_order'
  post 'pos/change_discount_type', to: 'pos#change_discount_type'
  resources :payment_methods
  resources :orders do
    member do
      get :print
    end
  end
  resources :order_payments, except: [ :edit, :update ]

  post 'pos/process_payment', to: 'pos#process_payment', as: :process_payment_pos
  get 'print_message', to: 'print#print_message'
  resources :purchases
  resource :settings, only: [ :edit ] do
    patch :update_all, on: :collection
  end
  resources :reports, only: [ :index ] do
    collection do
      get :products
      get :orders
      get :stocks
      get :expenses
    end
  end

  namespace :modal do
    resources :customers, only: [ :create ]
  end
  resources :orders do
    member do
      get :receipt_preview
    end
  end
end
