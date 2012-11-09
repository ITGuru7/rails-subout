Subout::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  namespace :api, defaults: {format: 'json'}  do
    namespace :v1 do
      resources :tokens
      resources :users
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

  resources :contacts, :employees, 
            :locations, :opportunity_types, 
            :profiles, :regions, :region_types, 
            :events,  :favorites

  resources :opportunities  do
    resources :bids
  end

  resources :auctions

  resources :favorite_invitations do
    collection do
      post :create_for_unknown_supplier, :create_for_known_supplier
    end

    member do
      get :accept
    end
  end

  resources :companies do
    member do
      get :new_supplier
    end
  end

  get 'dashboard', to: 'companies#dashboard'

  #TODO ask thomas about this
  match 'companies/events/:id' => 'companies#events'

  match 'companies/opportunities/:id' => 'companies#opportunities'
  match 'opportunities/bids/:id' => 'opportunities#bids'
  match 'api_login' => 'tokens#create'
end
