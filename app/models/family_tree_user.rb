# frozen_string_literal: true

class FamilyTreeUser < ApplicationRecord
  belongs_to :user
  belongs_to :family_tree
end
