# frozen_string_literal: true

module Api::V1
  class FamilyTreesController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :find_family_tree, only: %i[show update destroy timeline calendar person_tree rollback]

    resource_description do
      short 'Семейные деревья'
    end

    def_param_group :family_tree do
      property :id,             Integer,  desc: ''
      property :user_id,        Integer,  desc: ''
      property :name,           String,   desc: ''
      property :created_at,     DateTime, desc: ''
      property :updated_at,     DateTime, desc: ''
    end

    def_param_group :versions do
      property :id,             Integer,  desc: ''
      property :model,          String,   desc: ''
      property :model_id,       Integer,  desc: ''
      property :user_id,        Integer,  desc: ''
      property :family_tree_id, Integer,  desc: ''
      property :changes,        Hash,     desc: ''
      property :created_at,     DateTime, desc: ''
      property :updated_at,     DateTime, desc: ''
    end

    api :GET, '/v1/family_trees'
    returns array_of: :family_tree, code: 200, desc: 'просмотр всех своих деревьев'
    def index
      render json: family_trees, status: :ok
    end

    api :GET, '/v1/family_trees/:id'
    returns code: 200, desc: '' do
      property :family_tree, Hash, desc: '' do
        param_group :family_tree
      end
      property :persons, array_of: Hash,   desc: '' do
        property :id,             Integer, desc: ''
        property :last_name,      String,  desc: ''
        property :first_name,     String,  desc: ''
        property :middle_name,    String,  desc: ''
        property :maiden_name,    String,  desc: ''
        property :sex_id,         Integer, desc: ''
        property :father_id,      Integer, desc: ''
        property :mother_id,      Integer, desc: ''
        property :family_tree_id, Integer, desc: ''
        property :birthdate,      Date,    desc: ''
        property :deathdate,      Date,    desc: ''
        property :address,        String,  desc: ''
        property :contact,        String,  desc: ''
        property :document,       String,  desc: ''
        property :info,           String,  desc: ''
        property :created_at,     DateTime,desc: ''
        property :updated_at,     DateTime,desc: ''
        property :link_vk,        String,  desc: ''
        property :link_fb,        String,  desc: ''
        property :link_ig,        String,  desc: ''
        property :link_ok,        String,  desc: ''
        property :link_tg,        String,  desc: ''
        property :link_tw,        String,  desc: ''
        property :link_tt,        String,  desc: ''
        property :link_ch,        String,  desc: ''
        property :confirmed_last_name,   [true, false],  desc: ''
        property :confirmed_first_name,  [true, false],  desc: ''
        property :confirmed_middle_name, [true, false],  desc: ''
        property :confirmed_maiden_name, [true, false],  desc: ''
        property :confirmed_birthdate,   [true, false],  desc: ''
        property :confirmed_deathdate,   [true, false],  desc: ''
      end
      property :root_person_id, Integer, desc: ''
      property :persons_versions, array_of: Hash, desc: '' do param_group :versions end
      property :facts_versions,   array_of: Hash, desc: '' do param_group :versions end
    end
    def show
      persons = @family_tree.persons
      if @family_tree
        render json: {
            family_tree:      @family_tree,
            persons:          persons,
            # person_ids:       @family_tree.family_tree_users.map(&:root_person_id),
            root_person_id:   @family_tree.family_tree_users.find_by(user_id: @current_user.id).root_person_id,
            relations:        Relation.where(person_id: persons.ids).or(Relation.where(persona_id: persons.ids)).all
        }, status: :ok
      else
        render json: {}, status: :not_found
      end
    end

    api :GET, '/v1/family_trees/:id/person_tree'
    returns code: 200, desc: '' do
      property :root_person_id, Integer, desc: ''
    end
    def person_tree
      render json: {error: "family tree ##{params[:id]} not found for current user"} and return unless @family_tree

      persons = @family_tree.persons.order(:birthdate)
      root_id = params[:root_person_id]&.to_i || @family_tree_user.root_person_id
      relations = Relation.where(person_id: persons.ids).or(Relation.where(persona_id: persons.ids)).all
      render json: ApiPersonsService.new(persons, relations).find(root_id), status: :ok
    end

    api :POST, '/v1/family_trees'
    param :name, String, required: true
    returns code: 200, desc: '' do param_group :family_tree end
    def create
      @family_tree = FamilyTree.new(family_tree_params.merge(user_id: current_user.id, root_person_id: current_user.person.id))
      if @family_tree.save
        @family_tree.family_tree_users.create(user_id: current_user.id, role_id: Role[:owner].id)
        render json: @family_tree, status: :created
      else
        render json: @family_tree.errors, status: :unprocessable_entity
      end
    end

    api :PATCH, '/v1/family_trees/:id'
    param :id, Integer
    param :name, String
    param :root_person_id, Integer
    returns code: 200, desc: '' do param_group :family_tree end
    def update
      version = Version.prepare(method_name(caller(0)), @family_tree.id, @current_user, @family_tree, family_tree_params)
      if !@family_tree_user&.owner?
        render json: {error: 'you are not owner'}, status: :unprocessable_entity
      elsif @family_tree.update(family_tree_params)
        version.add
        render json: @family_tree, status: :ok
      else
        render json: @family_tree.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/v1/family_trees/:id'
    returns code: 200, desc: ''
    def destroy
      if !@family_tree_user.owner?
        render json: { status: :not_deleted, error: 'you are not owner' }, status: :unprocessable_entity
      elsif @family_tree.destroy
        render json: { status: :deleted }, status: :ok
      else
        render json: { status: :not_deleted }, status: :unprocessable_entity
      end
    end

    api :GET, '/v1/family_trees/:id/timeline'
    returns array_of: :versions, code: 200, desc: 'Лента новостей'
    def timeline
      @versions = Version.where(family_tree_id: @family_tree.id, deleted_at: nil)
                         .limit(params[:limit] || 50)
                         .offset(params[:offset] || 0)
                         .order(created_at: :desc)
                         .group_by do |x|
        z = x.created_at
        if params[:time_zone]&.to_i != 0
          tz = ActiveSupport::TimeZone.seconds_to_utc_offset(params[:time_zone].to_i)
          z = z.change(offset: tz) if tz
        end
        z.to_date
      end
      render json: @versions, status: :ok
    end

    api :GET, '/v1/family_trees/:id/calendar'
    returns array_of: :versions, code: 200, desc: 'События'
    param :month, String
    param :day,   String
    def calendar
      persons   = @family_tree.persons
      facts     =  Fact.where(person_id: persons.ids)
                       .where(fact_type_id: [FactType[:birth].id, FactType[:marriage].id, FactType[:death].id])
      facts     = facts.where("EXTRACT(MONTH FROM date) = ?", params[:month]) if params[:month]
      facts     = facts.where("EXTRACT(DAY   FROM date) = ?", params[:day])   if params[:day]
      @calendar = facts.order(:date).map do |fact|
        {
            type: FactType.cached_by_id[fact.fact_type_id].name,
            date: fact.date,
            info: fact.info,
            person_id: fact.person_id,
            person_name: persons.find { |p| p.id == fact.person_id }.full_name
        }
      end
      render json: @calendar, status: :ok
    end

    api :POST, '/v1/family_trees/:id/rollback'
    returns code: 200, desc: 'Откат последних изменений в семейном дереве'
    def rollback
      version = Version.where(family_tree_id: @family_tree.id, deleted_at: nil).last
      if !@family_tree_user.owner?
        render json: { status: :access_denied, error: 'you are not owner' }, status: :unprocessable_entity
      elsif version
        del_hash = { deleted_at: Time.now }
        model = version.model.constantize.find_by(id: version.model_id)
        version.update del_hash
        model.update  case version.event_type
                      when 'create' then del_hash
                      when 'destroy' then { deleted_at: nil}
                      else version.model_changes # if 'update'
                      end
        render json: { status: :success }, status: :ok
      else
        render json: { status: :unprocessable_entity }, status: :unprocessable_entity
      end
    end

    private

    def find_family_tree
      @family_tree = family_trees.find { |ft| ft.id == params[:id].to_i }
      @family_tree_user = @family_tree_users.find { |ftu| ftu.family_tree_id == @family_tree&.id && ftu.user_id == current_user.id }
    end

    def family_trees
      @family_tree_users ||= FamilyTreeUser.where(user_id: current_user.id).sort_by(&:role_id)
      @family_trees ||= FamilyTree.where(id: @family_tree_users.map(&:family_tree_id))
    end

    def family_tree_params
      params.permit(:name, :root_person_id)
    end
  end
end
