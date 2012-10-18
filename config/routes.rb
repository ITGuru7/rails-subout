Subout::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  namespace :api, defaults: {format: 'json'}  do
    namespace :v1 do
      resources :tokens
      resources :auctions
      resources :events
      resources :companies
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

  resources :auctions do
    put :select_winner, on: :member
  end

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

  root :to => redirect("/index_js")
end
