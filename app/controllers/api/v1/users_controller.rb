# frozen_string_literal: true

module Api::V1
  class UsersController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request, except: [:login, :check]

    resource_description do
      short 'Пользователи'
      # formats ['json']
      # meta author: {name: 'John', surname: 'Doe'}
    end

    def_param_group :user do
      param :uid,      String, required: true
      param :phone,    String, required: true
      param :provider, String, required: true
    end

    api :GET, '/v1/users/check'
    returns code: 200, desc: 'token' do
      property :user_exist, [true, false], desc: ''
    end
    def check
      phone = params[:phone].gsub(/\D/, '')
      user = User.where(phone: "+#{phone}", email: "+#{phone}@phone", provider: :phone).first
      render json: { user_exist: user.present? }
    end

    api :POST, '/v1/users/login', 'получение токена'
    param_group :user
    returns code: 200, desc: 'token' do
      property :auth_token, String, desc: 'token with expired date'
    end
    def login
      @user = User.find_for_oauth(params[:user])
      render(json: { error: 'Not Authorized' }, status: :unauthorized) and return unless @user&.persisted?

      sign_in @user, event: :authentication
      render json: { auth_token: JsonWebToken.encode(user_id: current_user.id) }
    end
  end
end
