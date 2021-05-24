Rails.application.routes.draw do
  # default_url_options protocol: :https, host: ENV['HOST'] || 'localhost:3000'
  default_url_options only_path: true
  apipie
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'users#new'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      namespace :dictionary do
        get :roles
        get :info_types
        get :relation_types
        get :sex
      end
      resources :family_trees, only: [:index, :show, :create, :update, :destroy] do
        get :timeline, on: :member
      end
      resources :persons, only: [:show, :create, :update, :destroy] do
        resources :archives, only: [:create, :update, :destroy]
        resources :photos,   only: [:create, :update, :destroy]
        resources :facts,    only: [:create, :update, :destroy, :show]
      end
      resources :relations, only: [:create, :update, :destroy]
      resources :users, only: [:show] do
        post :login, on: :collection
        get :check, on: :collection
      end
    end
  end

  resources :family_trees
  resources :persons do
    get :graph, on: :member
  end
  resources :users, only: [:new, :show] do
    post :create_user, on: :collection
    get :welcome, on: :collection
  end
end
