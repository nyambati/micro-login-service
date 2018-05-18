require "json_web_token"
module UsersSpecHelper
  def token_generator(user_data)
    JsonWebToken.encode(user_data)
  end

  def create_admin
    user = User.new(email: "kali@gmail.com", password: "kali2017")
    role = Role.new(name: "admin", domain: "https://www.google.com")
    user.save!
    user.assignments.create(role: role)
    user
  end
end
