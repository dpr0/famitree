# frozen_string_literal: true

module Api::V1
  class PersonsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :load_person, only: %i[show update destroy]
    before_action :load_family_tree, only: %i[create update]

    def show
      render json: @person, status: @person ? :ok : :not_found
    end

    def create
      @person = Person.new(person_params)
      if @person.save
        render json: @person, status: :created
      else
        render json: @person.errors, status: :unprocessable_entity
      end
    end

    def update
      if @person.update(person_params)
        render json: @person, status: :ok
      else
        render json: @person.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @person.destroy
      render json: { status: :deleted }, status: :ok
    end

    private

    def load_person
      @person = if params[:id] == current_user.person_id
                  current_user.person
                else
                  Person.where(family_tree_id: current_user.family_tree_users.map(&:family_tree_id)).find_by(id: params[:id])
                end
      render(json: { error: "person: #{params[:id]} - access denied"}, status: :unprocessable_entity) and return unless @person
    end

    def person_params
      params.require(:person).permit(
        :family_tree_id, :sex_id, :last_name, :first_name, :middle_name, :maiden_name, :father_id, :mother_id, :birthdate, :deathdate,
        :address, :contact, :document, :info, :link_vk, :link_fb, :link_ig, :link_ok, :link_tg, :link_tw, :link_tt, :link_ch
      )
    end

    def load_family_tree
      @family_tree = current_user.family_tree_users.find_by(family_tree_id: params[:family_tree_id])
      render(json: { error: "family_tree_id: #{params[:family_tree_id]} - access denied"}, status: :unprocessable_entity) and return unless @family_tree
    end
  end
end
