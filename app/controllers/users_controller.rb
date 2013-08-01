class UsersController < ApplicationController
  def authorized_organizations
    actions = params[:actions]
    if actions
      actions = actions.map(&:to_sym)
      authorized_organizations = []
      relationships = current_user.user_actions_organization_relationships
      relationships.each do |relationship|
        authorized_organizations << relationship.organization if actions - relationship.actions == []
      end
    else
      authorized_organizations = current_user.authorized_organizations
    end

    render json: authorized_organizations, each_serializer: AuthorizedOrganizationSerializer, root: :authorized_organizations
  end

  def recent_authorized_organizations
    data = {
      organization_ids: current_user.authorized_organizations.map(&:id),
      organization_clan_ids: []
    }
    render json: data
  end
  
end