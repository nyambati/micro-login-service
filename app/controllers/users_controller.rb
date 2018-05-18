class UsersController < ApplicationController
  include UsersHelper

  before_action :authenticate_request!, except: %i(login google_login create)
  before_action ->(param = params[:access_token]) do
    authenticate_with_access_token! param
  end, only: %i(create)
  before_action :set_user, only: %i(show update destroy)

  def index
    @users = User.all
    json_response(@users)
  end

  def create
    response = { error: Message.invalid_input }
    if !role_exists?
      json_response({ message: Message.invalid_input }, :bad_request)
    else
      users = user_params["users"]
      response = setup_users(users) unless users.blank?
      json_response(response, :created)
    end
  end

  def show
    json_response(@user)
  end

  def update
    email = user_params["email"]
    @user.update(email: email)
    if !role_exists? && !user_params["role"].blank?
      json_response({ message: Message.fake_role }, :bad_request) && return
    else
      set_role(@user)
      json_response(@user)
    end
  end

  def destroy
    @user.destroy
    json_response(message: Message.success)
  end

  def login
    user = User.find_by_email(user_params[:email].to_s.downcase)
    if user && user.authenticate(user_params[:password].to_s)
      generate_user_token user
    else
      json_response({ error: Message.invalid_credentials }, :unauthorized)
    end
  end

  def google_login
    redirect_url = request.env["omniauth.params"]["redirect_url"]
    if andela_mail?
      redirect_to(
        "https://api-prod.andela.com/login?redirect_url=#{redirect_url}"
      ) && return
    end
    email = request.env["omniauth.auth"][:info][:email]
    user = User.find_by_email(email)
    if user
      generate_google_token(user, redirect_url)
    else
      json_response({ error: Message.unauthorized }, :unauthorized)
    end
  end

  def generate_access_token
    token = @current_user.generate_access_token
    UserMailer.
      with(user: @current_user, access_token: token).
      notify_access_token.deliver_later
    json_response(message: "Please check your email for an access token")
  end

  private

  def user_params
    params.permit(
      :redirect_url,
      :state, :code, :provider,
      :role, :password, :access_token,
      :email, users: %i(firstname lastname email)
    )
  end
end
