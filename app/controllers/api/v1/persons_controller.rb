# frozen_string_literal: true

module Api::V1
  class PersonsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :load_person, only: %i[show update destroy avatar]
    before_action :load_family_tree, only: %i[create update]

    resource_description do
      short 'Родственники'
    end

    api :GET, '/v1/persons/:id'
    def show
      render json: {
          person:   @person,
          images:   @person.images_urls,
          facts:    @person.facts,
          avatar:   @person.avatar_url,
          childs:   Person.where(father_id: @person.id).or(Person.where(mother_id: @person.id)),
          versions: Version.changes(@person)
      },
      status: @person ? :ok : :not_found
    end

    api :POST, '/v1/persons'
    def create
      @person = Person.new(person_params)
      render_json(@person.save, @person)
    end

    api :PATCH, '/v1/persons/:id'
    def update
      Version.prepare(@person, person_params).add
      render_json(@person.update(person_params), @person)
    end

    api :DELETE, '/v1/persons/:id'
    def destroy
      @person.destroy
      render json: { status: :deleted }, status: :ok
    end

    api :GET, '/v1/persons/:id/avatar'
    def avatar
      if @person&.avatar&.attached?
        redirect_to rails_blob_url(@person.avatar)
      else
        head :not_found
      end
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
        :confirm_last_name, :confirm_first_name, :confirm_middle_name, :confirm_maiden_name, :confirm_birthdate, :avatar, :images,
        :address, :contact, :document, :info, :link_vk, :link_fb, :link_ig, :link_ok, :link_tg, :link_tw, :link_tt, :link_ch
      )
    end

    def load_family_tree
      @family_tree = current_user.family_tree_users.find_by(family_tree_id: person_params[:family_tree_id] || @person.family_tree_id)
      render(json: { error: "family_tree_id: #{params[:family_tree_id]} - access denied"}, status: :unprocessable_entity) and return unless @family_tree
    end
  end
end
