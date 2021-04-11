# frozen_string_literal: true

module Api::V1
  class FamilyTreesController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_request
    before_action :find_family_tree, only: %i[show update destroy]

    def index
      render json: family_trees, status: :ok
    end

    def show
      if @family_tree
        render json: { family_tree: @family_tree, persons: @family_tree.persons, root_person_id: @family_tree.root_person_id, versions: Version.changes(@family_tree) }, status: :ok
      else
        render json: {}, status: :not_found
      end
    end

    def create
      @family_tree = FamilyTree.new(family_tree_params.merge(user_id: current_user.id, root_person_id: current_user.person.id))
      if @family_tree.save
        @family_tree.family_tree_users.create(user_id: current_user.id, role_id: Role[:owner].id)
        render json: @family_tree, status: :created
      else
        render json: @family_tree.errors, status: :unprocessable_entity
      end
    end

    def update
      version = Version.prepare(@family_tree, family_tree_params)
      if !@family_tree_user&.owner?
        render json: {error: 'you are not owner'}, status: :unprocessable_entity
      elsif @family_tree.update(family_tree_params)
        version.add
        render json: @family_tree, status: :ok
      else
        render json: @family_tree.errors, status: :unprocessable_entity
      end
    end

    def destroy
      if !@family_tree_user.owner?
        render json: { status: :not_deleted, error: 'you are not owner' }, status: :unprocessable_entity
      elsif @family_tree.destroy
        render json: { status: :deleted }, status: :ok
      else
        render json: { status: :not_deleted }, status: :unprocessable_entity
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
