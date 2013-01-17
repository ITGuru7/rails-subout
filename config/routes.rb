require 'sidekiq/web'

Subout::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount ApiDoc => "/api/doc"

  namespace :api, defaults: {format: 'json'}  do
    namespace :v1 do
      resources :gateway_subscriptions do
        get :test_form, on: :collection
      end

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
      end
      resources :bids
      resources :filters
      resources :tags
      resources :opportunities do
        resources :bids
      end
    end
  end

  namespace :admin do
    get "/" => "base#index", as: :admin
    resources :gateway_subscriptions, only: [:index]
  end
end
