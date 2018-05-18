class Message
  def self.not_found(record = "record")
    "Sorry #{record} not found"
  end

  def self.invalid_token
    "Link not valid or expired."
  end

  def self.unauthorized
    "Unauthorized"
  end

  def self.expired_token
    "Sorry, your token has expired. Please login to continue."
  end

  def self.not_present
    "email not present"
  end

  def self.do_not_match
    "passwords do not match. please try again"
  end

  def self.fake_role
    "Role doesn't exist"
  end

  def self.success
    "Success"
  end

  def self.email_send
    "A link has been sent. Please check your email"
  end

  def self.not_verified
    "Email not Verified"
  end

  def self.invalid_credentials
    "Invalid Credentials"
  end

  def self.invalid_input
    "Invalid input"
  end

  def self.not_strong
    "Password must be 6 or more characters"
  end

  def self.invalid_domain
    "Please input a full valid domain url"
  end
end
