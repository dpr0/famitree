Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'users#show'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users, only: [:show] do
        post :login, on: :collection
        resources :family_trees, only: [:index, :show, :create, :update, :destroy] do
          resources :persons,    only: [:index, :show, :create, :update, :destroy]
        end
      end
    end
  end

  resources :users, only: [:show] do
    post :login, on: :collection
    resources :family_trees do
      resources :persons
    end
  end
end
