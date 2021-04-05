Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'users#new'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :family_trees, only: [:index, :show, :create, :update, :destroy]
      resources :persons,      only: [:show, :create, :update, :destroy] do
        get :avatar, on: :member
      end
      resources :facts,        only: [:create, :update, :destroy]
      resources :users, only: [:show] do
        post :login, on: :collection
        get :check, on: :collection
      end
    end
  end

  resources :family_trees
  resources :persons
  resources :users, only: [:new, :show] do
    post :create_user, on: :collection
    get :welcome, on: :collection
  end
end
