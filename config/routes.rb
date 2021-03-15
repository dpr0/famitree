Rails.application.routes.draw do
  resources :family_trees
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'users#show'

  resources :users, only: [:show]
  resources :persons
end
