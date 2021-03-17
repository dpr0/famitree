Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'users#show'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :family_trees, only: [:index, :show, :create, :update, :destroy]
      resources :persons,      only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:show] do
        post :login, on: :collection
      end
    end
  end

  resources :family_trees
  resources :persons
  resources :users, only: [:show] do
    post :login, on: :collection
  end
end
