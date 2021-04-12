# frozen_string_literal: true

class Person < ApplicationRecord
  include Rails.application.routes.url_helpers

  self.table_name = :persons

  has_one :user
  belongs_to :family_tree, required: false
  has_many :relations
  has_many :facts
  has_many :photos
  has_one_attached :avatar
  has_many_attached :images

  validate :acceptable_image

  def acceptable_image
    return unless avatar.attached?

    errors.add(:avatar, 'is too big') if avatar.byte_size > 1.megabyte
    errors.add(:avatar, 'must be a JPEG or PNG') unless ['image/jpeg', 'image/png'].include?(avatar.content_type)
  end

  def full_name
    maiden = maiden_name.present? ? "(#{maiden_name})" : ''
    "#{last_name}#{maiden} #{first_name} #{middle_name}"
  end

  def avatar_url
    url_for(avatar) if avatar.persisted?
  end

  def images_urls
    images.map do |i|
      url_for(i) if i.persisted?
    end
  end
end
