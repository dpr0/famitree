# frozen_string_literal: true

class PersonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person, only: %i[edit show update destroy]

  def show

  end

  def new
    @person = Person.new
  end

  def edit

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
    if @person.family_tree.user.id == current_user&.id
      @person.destroy
      render json: {status: :deleted}, status: :ok
    else
      render json: {status: :not_deleted}, status: :unprocessable_entity
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.fetch(:person, {})
  end
end
