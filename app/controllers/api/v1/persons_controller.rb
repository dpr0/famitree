# frozen_string_literal: true

module Api::V1
  class PersonsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :load_person, only: %i[show update destroy]
    before_action :load_family_tree, only: %i[create update]

    resource_description do
      short 'Родственники'
    end

    api :GET, '/v1/persons/:id'
    def show
      render json: {
          person:      @person,
          facts:       @person.facts.map    { |fact|       fact.attributes.merge(attachment:    fact.attachment_url) },
          photos:      @person.photos.map   { |photo|     photo.attributes.merge(attachment:   photo.attachment_url) },
          archives:    @person.archives.map { |archive| archive.attributes.merge(attachment: archive.attachment_url) },
          childs:      Person.where(father_id: @person.id).or(Person.where(mother_id: @person.id)),
          versions:    Version.changes(@person)
      },
      status: @person ? :ok : :not_found
    end

    api :POST, '/v1/persons'
    def create
      @person = Person.new(person_params)
      saved = @person.save
      Version.prepare(method_name(caller(0)), @person.family_tree.id, current_user, @person, params).add if saved
      render_json(saved, @person)
    end

    api :PATCH, '/v1/persons/:id'
    def update
      render_json(@person.update_with_version(method_name(caller(0)), @current_user, person_params), @person)
    end

    api :DELETE, '/v1/persons/:id'
    def destroy
      if @current_user.person == @person
        render json: { status: :not_deleted, reason: 'person belongs to user' }, status: :ok
      else
        params = { deleted_at: Time.now }
        method_name = method_name(caller(0))
        @person.update_with_version(method_name, @current_user, params)
        Person.where(father_id: @person.id).each { |child| child.update_with_version(method_name, @current_user, father_id: nil) }
        Person.where(mother_id: @person.id).each { |child| child.update_with_version(method_name, @current_user, mother_id: nil) }
        @person.photos.each   { |x| x.update(params)}
        @person.facts.each    { |x| x.update(params)}
        @person.archives.each { |x| x.update(params)}
        relations = Relation.where(person_id: @person.id).or(Relation.where(persona_id: @person.id)).all
        relations.each(&:destroy)
        render json: { status: :deleted }, status: :ok
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
        :confirm_last_name, :confirm_first_name, :confirm_middle_name, :confirm_maiden_name, :confirm_birthdate,
        :address, :contact, :document, :info, :link_vk, :link_fb, :link_ig, :link_ok, :link_tg, :link_tw, :link_tt, :link_ch
      )
    end

    def load_family_tree
      @family_tree = current_user.family_tree_users.find_by(family_tree_id: person_params[:family_tree_id] || @person.family_tree_id)
      render(json: { error: "family_tree_id: #{params[:family_tree_id]} - access denied"}, status: :unprocessable_entity) and return unless @family_tree
    end
  end
end
