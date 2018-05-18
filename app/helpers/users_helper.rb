require "generate_token"
module UsersHelper
  def role_exists?
    role = Role.find_by_name(user_params["role"])
    if role.blank?
      return false
    else
      return true
    end
  end

  def set_role(user)
    role = Role.find_by_name(user_params["role"])
    user.assignments.create(role: role)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def setup_users(users)
    response = { skiped: [], created: [] }
    users.each do |email|
      password = SecureRandom.hex(32)
      user = User.new(email: email, password: password,
                      password_confirmation: password)

      begin
        user.save!
        set_role(user)
        GenerateToken.generate_and_send_token_to(user)
        response[:created] << email
      rescue StandardError
        response[:skiped] << email
        next
      end
    end
    response
  end

  def generate_user_token(user)
    redirect_unconfirmed(user)
    auth_token = JsonWebToken.encode(UserInfo: {
                                       user_id: user.id,
                                       email: user.email,
                                       roles: user.roles.pluck(:name),
                                       domain: user.roles.pluck(:domain)
                                     })
    json_response(auth_token: auth_token)
  end

  def andela_mail?
    domain = request.env["omniauth.auth"][:info][:email].split("@").second
    true if domain == "andela.com"
  end

  def generate_google_token(user, url = "")
    if !user.confirmed_at?
      redirect_unconfirmed(user)
    else
      auth_token = JsonWebToken.encode(user_data(user))
      redirect_to(url + "?token=#{auth_token}")
    end
  end

  def redirect_unconfirmed(user)
    if user.confirmed_at?
      true
    else
      json_response({ error: Message.not_verified }, :unauthorized) && return
    end
  end

  def user_data(user)
    data = request.env["omniauth.auth"][:info]
    {
      UserInfo: {
        first_name: data[:first_name],
        last_name: data[:last_name],
        email: data[:email],
        image: data[:image],
        roles: user.roles.pluck(:name),
        domain: user.roles.pluck(:domain),
        user_id: user.id
      }
    }
  end
end
