require "uri"
module RolesHelper
  def get_role
    @role = Role.find(params[:id])
  end

  def domain_valid?(create_params)
    domain = create_params[:domain].to_s
    url_regex = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
    result = domain =~ url_regex
    result == 0
  end
end
