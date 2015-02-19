Rails.application.routes.draw do
 devise_for :cats, :controllers => { registrations: 'registrations' }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root 'cats#index'

  get '/login' => 'cats#login'
  post '/authenticate' => 'cats#authenticate', as: :authenticate
  get '/cats/edit' => 'cats#edit_cat_user', as: :edit_cat_user

  resources :cats

  scope :api do
  	get '/random' => 'cats#random'
  	get '/cats' => 'cats#api_index'
  	get '/cats/:id' => 'cats#show' 
  end
end