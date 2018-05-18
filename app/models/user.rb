require "fancy_id"
class User < ApplicationRecord
  self.primary_key = :userid
  has_secure_password

  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :email, with: /@/
  validates_presence_of :email, :password_digest, :firstname, :lastname

  before_save :downcase_data
  before_create :generate_confirmation_instructions

  has_many :assignments, primary_key: "userid",
                         foreign_key: "userid", dependent: :delete_all
  has_many :roles, -> { distinct }, through: :assignments

  def role?(role)
    roles.any? { |r| r.name.underscore.to_sym == role }
  end

  def downcase_data
    self.email = email.delete(" ").downcase
    self.firstname = firstname.delete(" ").downcase
    self.lastname = lastname.delete(" ").downcase
  end

  def generate_confirmation_instructions
    self.confirmation_token_digest = SecureRandom.hex(64).to_s
    self.confirmation_sent_at = Time.now.utc
  end

  def confirmation_token_valid?(token)
    candidate = Digest::SHA512.hexdigest(token)
    (confirmation_sent_at + 24.hours) > Time.now.utc &&
      confirmation_token_digest == candidate
  end

  def mark_as_confirmed!
    self.confirmation_token_digest = nil
    self.confirmed_at = Time.now.utc
    save
  end

  def reset_password!(password)
    self.password = password
    save!
  end

  def generate_access_token
    access_token = SecureRandom.hex(64).to_s
    self.access_token_digest = Digest::SHA512.hexdigest(access_token)
    save!
    access_token
  end

  before_create do
    self.userid = generate_id
  end
end
