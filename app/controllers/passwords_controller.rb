class PasswordsController < ApplicationController
  require "reset"
  def forgot
    render Reset.new.forgot_password(params)
  end

  private

  def user_params
    params.permit(
      :email,
      :password,
      :password_confirmation,
      :token
    )
  end
end
