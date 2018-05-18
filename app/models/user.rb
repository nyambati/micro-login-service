class User < ApplicationRecord
  has_secure_password

  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :email, with: /@/
  validates_presence_of :email, :password_digest

  before_save :downcase_email
  before_create :generate_confirmation_instructions

  has_many :assignments
  has_many :roles, through: :assignments

  def role?(role)
    roles.any? { |r| r.name.underscore.to_sym == role }
  end

  def downcase_email
    self.email = email.delete(" ").downcase
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
end
