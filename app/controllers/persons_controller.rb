# frozen_string_literal: true

class PersonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_person, only: %i[edit show update destroy]
  before_action :mens_and_womens, only: %i[edit new]

  def show; end

  def new
    @family_tree = @person.family_tree
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
        format.html { redirect_to family_tree_path(@person.family_tree_id), notice: 'Родственник обновлён.' }
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
    @family_tree = @person.family_tree
    @family_tree_user = @family_tree.family_tree_users.find { |ft| ft.family_tree_id == @person.family_tree_id && ft.user_id == current_user.id }
  end

  def mens_and_womens
    @person ||= Person.new(family_tree_id: params[:family_tree_id])
    @mens = @family_tree.persons.where(sex_id: [Sex[:male].id]).where.not(id: [@person.id])
    @womens = @family_tree.persons.where(sex_id: Sex[:female].id).where.not(id: [@person.id])
  end

  def person_params
    params.require(:person).permit(
      :family_tree_id, :sex_id, :last_name, :first_name, :middle_name, :maiden_name, :father_id, :mother_id, :birthdate, :address, :contact, :document, :info
    )
  end
end
