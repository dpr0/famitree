# frozen_string_literal: true

class FamilyTreesController < ApplicationController
  before_action :set_family_tree, only: %i[show update destroy]

  def index
    @family_trees = current_user ? FamilyTree.where(user_id: current_user.id).all : []
    render json: @family_trees, status: :ok
  end

  def show
    render json: {family_tree: @family_tree, persons: @family_tree.persons}, status: :ok
  end

  def create
    @family_tree = current_user.family_trees.new(family_tree_params)
    if @family_tree.save
      render json: @family_tree, status: :created
    else
      render json: @family_tree.errors, status: :unprocessable_entity
    end
  end

  def update
    if @family_tree.update(family_tree_params)
      render json: @family_tree, status: :ok
    else
      render json: @family_tree.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @family_tree.user.id == current_user&.id
      @family_tree.destroy
      render json: {status: :deleted}, status: :ok
    else
      render json: {status: :not_deleted}, status: :unprocessable_entity
    end
  end

  private

  def set_family_tree
    @family_tree = FamilyTree.find(params[:id])
  end

  def family_tree_params
    params.fetch(:family_tree, {})
  end
end
