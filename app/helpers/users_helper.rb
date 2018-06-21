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
    response = { skiped: [], created: [], info: [] }
    users.each do |user|
      password = SecureRandom.hex(32)
      user = User.new(email: user["email"], password: password,
                      firstname: user["firstname"], lastname: user["lastname"],
                      password_confirmation: password)

      begin
        if User.exists?(email: user["email"])
          user = User.find_by_email(user["email"])
          set_role(user)
          response[:info] << "Role (Re)assigned to '#{user['email']}'"
          next
        end
        user.save!
        set_role(user)
        GenerateToken.generate_and_send_token_to(user)
        response[:created] << user["email"]
      rescue StandardError => e
        response[:skiped] << { user["email"] => e.message }
        next
      end
    end
    response
  end

  def generate_user_token(user)
    redirect_unconfirmed(user)
    auth_token = JsonWebToken.encode(
      UserInfo: {
        id: user.id,
        email: user.email,
        first_name: user.firstname.titleize,
        last_name: user.lastname.titleize,
        name: "#{user.firstname.titleize} #{user.lastname.titleize}",
        picture: "https://ui-avatars.com/api/?"\
                 "name=#{user.firstname.titleize} #{user.lastname.titleize}"\
                 "&background=195BDC&color=fff&size=128",
        roles: get_all_roles(user),
        domains: user.roles.pluck(:domain)
      }
    )
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

  def get_all_roles(user)
    user_roles = {}
    user.roles.each do |role|
      user_roles[role.name] = role.id
    end
    user_roles
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
        id: user.id,
        first_name: data[:first_name],
        last_name: data[:last_name],
        name: "#{data[:first_name]} #{data[:last_name]}",
        email: data[:email],
        picture: data[:image],
        roles: get_all_roles(user),
        domains: user.roles.pluck(:domain)
      }
    }
  end
end
