# frozen_string_literal: true

class Person < ApplicationRecord
  self.table_name = :persons

  has_one :user
  belongs_to :family_tree, required: false
  has_many :relations
  has_many :facts
  has_one_attached :main_image

  validate :acceptable_image

  def acceptable_image
    return unless main_image.attached?

    errors.add(:main_image, 'is too big') unless main_image.byte_size <= 1.megabyte
    errors.add(:main_image, 'must be a JPEG or PNG') unless ['image/jpeg', 'image/png'].include?(main_image.content_type)
  end

  def full_name
    maiden = maiden_name.present? ? "(#{maiden_name})" : ''
    "#{last_name}#{maiden} #{first_name} #{middle_name}"
  end
end
