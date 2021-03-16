# frozen_string_literal: true

module Api::V1
  class ApplicationController < ActionController::Base

    private

    def authenticate_request
      @current_user = User.auth_by_token(request.headers)
      render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end
  end
end
