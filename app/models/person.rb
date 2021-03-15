# frozen_string_literal: true

class Person < ApplicationRecord
  self.table_name = :persons

  belongs_to :family_tree
  has_many :relations
end
