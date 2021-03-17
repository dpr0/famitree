# frozen_string_literal: true

class PersonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person, only: %i[edit show update destroy]

  def show; end

  def new
    @person = Person.new
  end

  def edit; end

  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to family_tree_path(@person.family_tree_id), notice: 'Родственник создан.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to family_trees_path, notice: 'Родственник обновлён.' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @person.family_tree.user.id == current_user&.id
      @person.destroy
      respond_to do |format|
        format.html { redirect_to family_trees_url, notice: 'Родственник удалён.' }
        format.json { head :no_content }
      end
    else
      render json: {status: :not_deleted}, status: :unprocessable_entity
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(
      :family_tree_id, :sex_id, :last_name, :first_name, :middle_name, :maiden_name, :father_id, :mother_id, :birthdate, :address, :contact, :document, :info
    )
  end
end
