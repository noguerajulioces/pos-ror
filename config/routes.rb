Rails.application.routes.draw do
  root 'home#index'
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

  post 'pos/add_product_to_cart', to: 'pos#add_product_to_cart'
  post 'pos/add_product_to_order', to: 'pos#add_product_to_order'
  post 'pos/clear_cart', to: 'pos#clear_cart'
  delete 'pos/remove_from_cart', to: 'pos#remove_from_cart'
  post 'pos/set_customer', to: 'pos#set_customer'
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
      get 'discount', to: 'discounts#show'
    end
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

  patch 'pos/update_quantity', to: 'pos#update_quantity'
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
end
