# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable, :recoverable, :rememberable,
         :validatable, :omniauthable, omniauth_providers: [:firebase, :telegram, :yandex]

  has_many :authorizations, dependent: :destroy
  has_many :family_tree_users
  has_many :family_trees, through: :family_tree_users, inverse_of: :users, dependent: :destroy
  belongs_to :person, required: false

  def self.find_for_oauth(auth)
    authorization = Authorization.where(provider: auth[:provider], uid: auth[:uid]).first
    return authorization.user if authorization

    user = User.where(email: auth[:email], provider: auth[:provider]).first
    if user
      user.uid ||= auth[:uid]
      user.name = auth[:name] if auth[:name].present?
      user.person ||= Person.create!({last_name: user.last_name, first_name: user.first_name, middle_name: user.middle_name, }.merge(auth[:phone] ? {contact: auth[:phone]} : {}))
    else
      user = User.new(auth)
      user.person = Person.create!({last_name: auth[:name]}.merge(auth[:phone] ? {contact: auth[:phone]} : {}))
    end
    user.save!
    user.create_authorization(auth)
    user
  end

  def self.create_user(p)
    p[:birthdate] = p[:birthdate]&.to_date
    phone = p[:phone].gsub(/[^\d]/, '')
    p[:phone] = phone.size == 10 ? "+7#{phone}" : nil
    p[:email] = "#{phone}@phone" if phone
    p[:provider] = 'phone'
    user = User.new(p)
    user.name = user.full_name
    user.password = Devise.friendly_token[0, 20]
    user
  end

  def self.auth_by_token(headers)
    @current_user = if headers['Authorization'].present?
      hash = JsonWebToken.decode(headers['Authorization'].split(' ').last)
      User.find(hash[:user_id]) if hash[:user_id]
    end
  end

  def create_authorization(auth)
    authorizations.create(provider: auth[:provider], uid: auth[:uid])
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}"
  end
end
