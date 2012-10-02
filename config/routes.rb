Subout::Application.routes.draw do

  devise_for :users

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

  root :to => 'companies#dashboard'
end
