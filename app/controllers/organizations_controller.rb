class OrganizationsController < ApplicationController
  before_filter :ensure_organization, only: [:create_children, :update, :destroy, :authorized_users]
  before_filter :authorize_create_organization!, only: [:create_children]
  before_filter :authorize_delete_organization!, only: [:destroy]
  before_filter :authorize_edit_organization!, only: [:update]
  def index
    @organizations = Organization.all
    render json: @organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations
  end

  # FIXME: authorize the new child, when create new child
  def create_children
    @organization = @organization.children.new(params[:organization])
    if @organization.save
      render json: @organization, status: :created, serializer: AuthorizedOrganizationSerializer, root: :organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      head :no_content
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.destroy
    head :no_content
  end

  def authorized_users
    authorized_users = @organization.authorized_users
    render json: authorized_users, each_serializer: BasicUserSerializer, root: :authorized_users
  end

  # OPTIMIZE: need refactory
  def all_members
    @organization = Organization.find(params[:id])
    if params[:id] == 'not_exists'
      members = User.all
    else
      if @organization
        members = @organization.members
      else
        return not_found!
      end
    end
    render json: members, each_serializer: CustomMemberSerializer, root: :members
  end

  private
  def ensure_organization
    @organization = Organization.where(id: params[:id]).first
    raise Youxin::NotFound unless @organization
  end
end
