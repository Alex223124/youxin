class UserController < ApplicationController
  def organizations
    organizations = current_user.organizations
    render json: organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations    
  end
end