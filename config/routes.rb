require 'sidekiq/web'

Subout::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount ApiDoc => "/api/doc"

  root :to => 'static#index'
  get '/' => 'static#index'
  get '/index.html' => 'static#index'

  # this is used for cache busting locally
  if Rails.env.development?
    get '/files/:timestamp/:path' => 'static#asset', :constraints => { :path => /.+/ }
  end

  devise_for :users, skip: [:registrations, :sessions, :passwords, :confirmations]

  namespace :api, defaults: {format: 'json'}  do
    namespace :v1 do
      resources :gateway_subscriptions do
        get :connect_company, on: :collection
      end
      resources :products
      resources :file_uploader_signatures, only: :new
      resources :passwords do
        put "update", on: :collection
      end
      resources :tokens
      resources :users  do
        collection do
          post :account
        end
      end

      resources :auctions do
        member do
          put :select_winner
          put :cancel
        end
      end

      resources :favorite_invitations do
        collection do
          post :create_for_unknown_supplier
        end

        member do
          get :accept
        end
      end

      resources :favorites
      resources :events
      resources :companies do
        get :search, on: :collection
        put :update_regions, on: :member
        put :update_product, on: :member
      end

      resources :regions

      resources :bids
      resources :filters
      resources :tags
      resources :opportunities do
        resources :bids
        resources :comments
      end
    end
  end

  namespace :admin do
    get "/" => "base#index"
    resources :gateway_subscriptions, only: [:index, :edit, :update] do
      put 'resend_invitation', on: :member
    end
    resources :companies, only: [:index]
    resources :favorite_invitations, only: [:index] do
      put 'resend_invitation', on: :member
    end
  end
end
