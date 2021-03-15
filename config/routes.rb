Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  root 'manufacturers#index'

  resources :users, only: [:index, :show]
  resources :manufacturers

  resources :sections do
    resources :persons do
      resources :subpersons do
        resources :items do
          resources :modifications do
            post :favourite, on: :collection
          end
          post :filter, on: :member
        end
      end
    end
  end
end
