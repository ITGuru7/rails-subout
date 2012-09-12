Subout::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  resources :bids, :contacts, :employees, 
            :favorites, :locations, :opportunities, :opportunity_types, 
            :profiles, :regions, :region_types, 
            :events, :companies

  get 'dashboard', to: 'companies#dashboard'

  #TODO ask thomas about this
  match 'companies/events/:id' => 'companies#events'

  match 'companies/opportunities/:id' => 'companies#opportunities'
  match 'opportunities/bids/:id' => 'opportunities#bids'
  match 'api_login' => 'tokens#create'

  root :to => 'companies#dashboard'
end
