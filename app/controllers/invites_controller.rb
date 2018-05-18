class InvitesController < ActionController::Base
  require "reset"

  def index
    user = load_user
    token = params[:token].to_s
    if user.present? && user.confirmation_token_valid?(token)
      @show_form = true
    end
  end

  def create
    if params[:broken]
      @response = Reset.new.forgot_password(params)
      render("index") && return
    end
    reset = Reset.new
    user = reset.get_user(params[:token].to_s)
    @response = reset.reset_password(params)
    @token = params[:token]
    @show_form = true unless @response[:json][:error] == Message.invalid_token
    if @response[:json][:status] == Message.success
      domain = user.roles.pluck(:domain).last
      redirect_to(domain)
    else
      render "index"
    end
  end

  private

  def load_user
    token = params[:token].to_s
    user = (Reset.new.get_user(params[:token]) unless token.blank?)
    user
  end
end
