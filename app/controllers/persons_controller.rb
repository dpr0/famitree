# frozen_string_literal: true

class PersonsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_person, only: %i[edit show update destroy]
  before_action :family_trees, only: %i[new edit]
  before_action :mens_and_womens, only: %i[edit new]

  def show
    redirect_to family_trees_path unless @person
  end

  def new; end

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
      render json: { status: :not_deleted }, status: :unprocessable_entity
    end
  end

  private

  def load_person
    @person = if params[:id] == current_user.person_id
                current_user.person
              else
                Person.where(family_tree_id: current_user.family_tree_users.map(&:family_tree_id)).find_by(id: params[:id])
              end
    @family_tree = @person&.family_tree
    @family_tree_user = @family_tree.family_tree_users.find { |ft| ft.family_tree_id == @person.family_tree_id && ft.user_id == current_user.id } if @family_tree
  end

  def family_trees
    @family_trees = FamilyTree.where(id: current_user.family_tree_users.map(&:family_tree_id))
  end

  def mens_and_womens
    @person ||= Person.new(family_tree_id: params[:family_tree_id])
    @family_tree ||= FamilyTree.find(params[:family_tree_id]) if params[:family_tree_id]
    if @family_tree
      @mens = @family_tree.persons.where(sex_id: [Sex[:male].id]).where.not(id: [@person.id])
      @womens = @family_tree.persons.where(sex_id: Sex[:female].id).where.not(id: [@person.id])
    end
  end

  def person_params
    params.require(:person).permit(
      :family_tree_id, :sex_id, :last_name, :first_name, :middle_name, :maiden_name, :father_id, :mother_id, :birthdate, :deathdate, :address, :contact, :document, :info
    )
  end
end
