# frozen_string_literal: true

class FamilyTreesController < ApplicationController
  before_action :set_family_tree, only: %i[show edit update destroy]

  def index
    @family_trees = FamilyTree.where(user_id: current_user.id).all if current_user
  end

  def show
    render plain: @family_tree.to_json, status: 200, content_type: 'application/json'
  end

  def new
    @family_tree = FamilyTree.new
  end

  def edit; end

  def create
    @family_tree = FamilyTree.new(family_tree_params)

    respond_to do |format|
      if @family_tree.save
        format.html { redirect_to @family_tree, notice: 'Family tree was successfully created.' }
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
        format.html { redirect_to @family_tree, notice: 'Family tree was successfully updated.' }
        format.json { render :show, status: :ok, location: @family_tree }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @family_tree.destroy
    respond_to do |format|
      format.html { redirect_to family_trees_url, notice: 'Family tree was successfully destroyed.' }
      format.json { head :no_content }
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
