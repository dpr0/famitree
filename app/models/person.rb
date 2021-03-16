# frozen_string_literal: true

class Person < ApplicationRecord
  self.table_name = :persons

  has_one :user
  belongs_to :family_tree
  has_many :relations

  def full_name
    maiden = maiden_name ? "(#{maiden_name})" : ""
    "#{last_name}#{maiden} #{first_name} #{middle_name}"
  end
end
