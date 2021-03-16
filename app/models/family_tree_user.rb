# frozen_string_literal: true

class FamilyTreeUser < ApplicationRecord
  self.table_name = :family_trees_users

  belongs_to :user
  belongs_to :family_tree
end
