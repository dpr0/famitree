# frozen_string_literal: true

class FamilyTree < ApplicationRecord
  belongs_to :user
  has_many :persons
end
