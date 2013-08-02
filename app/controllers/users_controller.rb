class UsersController < ApplicationController
  before_filter :find_user, only: [:update]
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

  def update
    if @user.update_attributes params[:user]
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def create
    attrs = attributes_for_keys [:name, :phone]
    password = Devise.friendly_token.first(8)
    email = "#{phone}@combee.com"
    attrs.merge!({ password: password, password_confirmation: password })
    user = User.new attrs
    if user.save
      render json: user, status: :created
    else
      render json: user.errors, status: :unprocessable_entity 
    end
  end
  
  private
  def find_user
    @user = User.where(id: params[:id]).first
    return not_found! unless @user
  end
end