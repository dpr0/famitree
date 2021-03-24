# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: :show

  def new
    redirect_to user_path(current_user.id) if user_signed_in?
    @user = User.new
  end

  def show
    @trees = FamilyTreeUser.where(user_id: current_user.id).group_by(&:role_id)
  end

  def create_user
    @user = User.create_user(create_user_params)

    respond_to do |format|
      if @user.phone && @user.save
        format.html { redirect_to welcome_users_path }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def welcome; end

  private

  def create_user_params
    params.require(:user).permit(:last_name, :first_name, :middle_name, :birthdate, :phone)
  end
end
