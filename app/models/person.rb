# frozen_string_literal: true

class Person < ApplicationRecord
  self.table_name = :persons

  has_one :user
  belongs_to :family_tree, required: false
  has_many :relations
  has_many :facts
  has_many :photos
  has_one_attached :avatar

  validate :acceptable_image

  def acceptable_image
    return unless avatar.attached?

    errors.add(:avatar, 'is too big') unless avatar.byte_size <= 1.megabyte
    errors.add(:avatar, 'must be a JPEG or PNG') unless ['image/jpeg', 'image/png'].include?(avatar.content_type)
  end

  def full_name
    maiden = maiden_name.present? ? "(#{maiden_name})" : ''
    "#{last_name}#{maiden} #{first_name} #{middle_name}"
  end

  def versions
    Version.where(model: self.class.name, model_id: id).order(created_at: :DESC)
  end
end
