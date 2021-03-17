# frozen_string_literal: true

class FamilyTreesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family_tree, only: %i[edit show update destroy]

  def index
    @family_tree_users = current_user ? current_user.family_tree_users.sort_by(&:role_id) : []
  end

  def show
    (redirect_to family_trees_path and return) if @family_tree.nil? || !current_user.family_tree_users.map(&:family_tree_id).include?(@family_tree.id)
    @persons = @family_tree.persons
    @relations = Relation.where(person_id: @persons.ids).or(Relation.where(persona_id: @persons.ids)).all
  end

  def new
    @family_tree = FamilyTree.new
  end

  def edit; end

  def create
    @family_tree = FamilyTree.new(family_tree_params.merge(user_id: current_user.id))
    @family_tree.family_tree_users.new(user_id: current_user.id, role_id: Role[:owner].id)

    respond_to do |format|
      if @family_tree.save
        format.html { redirect_to family_trees_path, notice: 'Семейное дерево создано.' }
        format.json { render :show, status: :created, location: @family_tree }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @family_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @family_tree.update(family_tree_params)
        format.html { redirect_to family_trees_path, notice: 'Семейное дерево обновлено.' }
        format.json { render :show, status: :ok, location: @family_tree }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    return if @family_tree.user_id != current_user&.id

    @family_tree.destroy
    respond_to do |format|
      format.html { redirect_to family_trees_url, notice: 'Семейное дерево удалено.' }
      format.json { head :no_content }
    end
  end

  private

  def set_family_tree
    @family_tree = FamilyTree.find_by(id: params[:id])
  end

  def family_tree_params
    params.require(:family_tree).permit(:name)
  end
end
