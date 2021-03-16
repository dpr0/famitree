# frozen_string_literal: true

module Api::V1
  class UsersController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request, except: :login

    def show

    end

    def login
      @user = User.find_for_oauth(params[:user])
      render(json: {}, status: :unauthorized) unless @user.persisted?

      sign_in @user, event: :authentication
      render json: { auth_token: JsonWebToken.encode(user_id: current_user.id) }
    end
  end
end
