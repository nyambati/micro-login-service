require "roles_helper"

class RolesController < ApplicationController
  include RolesHelper
  before_action :authenticate_request!
  before_action :get_role, only: %i(show update destroy)

  def index
    @roles = Role.all
    json_response(@roles)
  end

  def show
    json_response(@role)
  end

  def update
    if !domain_valid?(role_params)
      json_response({ error: Message.invalid_domain }, :bad_request)
    else
      @role.update(role_params)
      json_response(@role)
    end
  end

  def destroy
    @role.destroy
    json_response(message: Message.success)
  end

  def create
    if !domain_valid?(create_params)
      json_response({ error: Message.invalid_domain }, :bad_request)
    else
      @role = Role.new(create_params)
      @role.save!
      json_response(@role, :created)
    end
  end

  private

  def role_params
    params.permit(:name, :domain)
  end

  def create_params
    params.require(:domain)
    params.require(:name)
    params.permit(:name, :domain)
  end
end
