# frozen_string_literal: true

module Api::V1
  class FactsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :load_person
    before_action :load_fact, only: %i[update destroy]

    def create
      @fact = Fact.new(fact_params)
      render_json(@fact.save, @fact)
    end

    def update
      render_json(@fact.update(person_params), @fact)
    end

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
      params.require(:fact).permit(:person_id, :date, :info)
    end

    def load_person
      @person = Person.find_by(family_tree_id: current_user.family_tree_users(&:family_tree_id), id: fact_params[:person_id])
      render(json: { error: "person: #{fact_params[:person_id]} - access denied"}, status: :unprocessable_entity) and return unless @person
    end
  end
end
