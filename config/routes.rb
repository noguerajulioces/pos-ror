Rails.application.routes.draw do
  root "home#index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

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
  end
  resources :stocks, only: [ :index ]
  resources :units, except: %i[show]
  resources :customers do
    collection do
      get "search"
    end
  end
  resources :suppliers
  resources :users
  resources :expenses
  resource :pos, only: [ :show ]
  patch "pos/update_order_type", to: "pos#update_order_type"
  get "pos/order_type_modal", to: "pos#order_type_modal"
  # Add this route alongside your other routes
  get "pos/customer_search_modal", to: "pos#customer_search_modal"
  get "pos/orders_modal", to: "pos#orders_modal"
  # Add this route alongside your other routes
  get "pos/subcategories", to: "pos#subcategories"
  # Add this route alongside your other routes
  get "pos/products_by_subcategory", to: "pos#products_by_subcategory"
  # Add this line to your routes.rb
  # Add this line if it doesn't exist
  post "pos/add_product_to_cart", to: "pos#add_product_to_cart"
  post "pos/add_product_to_order", to: "pos#add_product_to_order"
  # Add this line to your routes.rb
  post "pos/clear_cart", to: "pos#clear_cart"
  # Add this line to your routes.rb
  delete "pos/remove_from_cart", to: "pos#remove_from_cart"
  # Add this route within your routes.rb file
  post "pos/set_customer", to: "pos#set_customer"
  # Make sure this route is defined
  post "pos/set_order_type", to: "pos#set_order_type"
  # Add this route within your routes.rb file
  get "pos/search_products", to: "pos#search_products"
  # Add these routes to your routes.rb file
  resources :cash_registers, only: [ :create ]
  get "pos/cash_register_modal", to: "pos#cash_register_modal"
end
