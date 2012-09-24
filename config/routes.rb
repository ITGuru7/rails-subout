Subout::Application.routes.draw do

  devise_for :users

  resources :bids, :contacts, :employees, 
            :locations, :opportunities, :opportunity_types, 
            :profiles, :regions, :region_types, 
            :events, :companies, :favorites 

  resources :favorite_invitations do
    #collection do
      #post :create_unknown_invitation
    #end

    member do
      get :accept
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
