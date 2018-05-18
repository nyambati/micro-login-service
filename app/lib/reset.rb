require "generate_token"
class Reset
  include ResetResponse

  def attempt_to_db(user, user_params)
    if user.reset_password!(user_params[:password])
      user.mark_as_confirmed!
      reset_response(status: Message.success)
    else
      reset_response({ error: user.errors.full_messages },
                     :unprocessable_entity)
    end
  end

  def check_email_presence(user_params)
    if user_params[:email].blank?
      reset_response({ error: Message.not_present }, :bad_request)
    end
  end

  def check_passwords_match(user, user_params)
    if !user_params[:password].blank? && (user_params[:password].length >= 6)
      if user_params[:password] == user_params[:password_confirmation]
        attempt_to_db user, user_params
      else
        reset_response({ error: Message.do_not_match }, :bad_request)
      end
    else
      reset_response({ error: Message.not_strong }, :bad_request)
    end
  end

  def get_user(token)
    candidate = Digest::SHA512.hexdigest(token)
    user = User.find_by_confirmation_token_digest(candidate)
    user
  end

  def forgot_password(user_params)
    check_email_presence(user_params)
    user = User.find_by_email(user_params[:email].to_s.downcase)

    if user.present?
      user.generate_confirmation_instructions
      GenerateToken.generate_and_send_token_to(user, "forgot")
      reset_response(linkSent: Message.email_send)
    else
      reset_response({ error: Message.not_found }, :not_found)
    end
  end

  def reset_password(params)
    check_email_presence(params)
    user = get_user(params[:token])
    if user.present? && user.confirmation_token_valid?(params[:token])
      check_passwords_match user, params
    else
      reset_response({ error: Message.invalid_token }, :not_found)
    end
  end
end
