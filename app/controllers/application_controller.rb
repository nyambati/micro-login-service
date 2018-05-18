class ApplicationController < ActionController::API
  require "json_web_token"
  include GenerateToken
  include Response
  include ExceptionHandler
  include ActionController::Serialization

  protected

  def authenticate_request!
    if !payload || !JsonWebToken.valid_payload(payload.first)
      return invalid_authentication
    end

    load_current_user!
    invalid_authentication unless @current_user
  end

  def invalid_authentication
    json_response({ error: "Unauthorized" }, :unauthorized)
  end

  def authenticate_with_access_token!(access_token)
    access_token = get_auth_header(access_token).to_s
    access_digest = Digest::SHA512.hexdigest(access_token)
    @current_user = User.find_by_access_token_digest(access_digest)
    authenticate_request! unless @current_user
  end

  private

  def payload
    token = get_auth_header
    JsonWebToken.decode(token)
  rescue StandardError
    nil
  end

  def load_current_user!
    selected_user = User.find_by_email(payload[0]["UserInfo"]["email"])
    if selected_user && selected_user.roles.exists?(name: "admin")
      @current_user = selected_user
    end
  end

  def get_auth_header(access_token = "")
    auth_header = if access_token.blank?
                    request.headers["Authorization"]
                  else
                    access_token
                  end
    token = auth_header.split(" ").last
    token.to_s
  rescue NoMethodError
    nil
  end
end
