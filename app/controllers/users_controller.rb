# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @trees = FamilyTreeUser.where(user_id: current_user.id).group_by(&:role_id)
  end
end
