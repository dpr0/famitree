# frozen_string_literal: true

module Api::V1
  class FactsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :load_person
    before_action :load_fact, only: %i[update destroy]

    resource_description do
      short 'Факты (Биография)'
    end

    def_param_group :fact do
      property :id, Integer, desc: ''
      param_group :fact_short
      property :created_at, DateTime, desc: ''
      property :updated_at, DateTime, desc: ''
    end

    def_param_group :fact_short do
      param :person_id,    Integer, required: true
      param :date,         String
      param :info,         String
      param :info_type_id, Integer
    end

    api :GET, '/v1/facts/:id'
    returns code: 200, desc: '' do
      property :fact, Hash, desc: '' do
        param_group :fact
      end
      property :versions, array_of: Hash, desc: '' do
        property :id,         Integer, desc: ''
        property :model,      String,  desc: ''
        property :model_id,   Integer, desc: ''
        property :changes,    Hash,    desc: ''
        property :created_at, DateTime,desc: ''
        property :updated_at, DateTime,desc: ''
      end
    end
    def show
      render json: { fact: @fact, versions: Version.changes(@fact) }, status: @person ? :ok : :not_found
    end

    api :POST, '/v1/facts'
    param_group :fact_short
    returns code: 200, desc: '' do param_group :fact end
    def create
      @fact = Fact.new(fact_params)
      render_json(@fact.save, @fact)
    end

    api :PATCH, '/v1/facts/:id'
    param_group :fact_short
    returns code: 200, desc: '' do param_group :fact end
    def update
      Version.prepare(@fact.person.family_tree.id, @current_user.id, @fact, fact_params).add
      render_json(@fact.update(fact_params), @fact)
    end

    api :DELETE, '/v1/facts/:id'
    returns code: 200, desc: ''
    def destroy
      @fact.destroy
      render json: { status: :deleted }, status: :ok
    end

    private

    def load_fact
      @fact = Fact.find_by(id: params[:id])
      render(json: { error: "fact: #{params[:id]} - access denied"}, status: :unprocessable_entity) and return unless @fact
    end

    def fact_params
      params.require(:fact).permit(:person_id, :date, :info, :info_type_id)
    end

    def load_person
      @person = Person.find_by(family_tree_id: current_user.family_tree_users(&:family_tree_id).map(&:family_tree_id), id: fact_params[:person_id])
      render(json: { error: "person: #{fact_params[:person_id]} - access denied"}, status: :unprocessable_entity) and return unless @person
    end
  end
end
