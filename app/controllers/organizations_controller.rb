class OrganizationsController < ApplicationController
  before_filter :find_organization, only: [:create, :update, :destroy, :authorized_users]
  # create children, require parent
  before_filter :authorize_create_organization!, only: [:create]
  before_filter :authorize_delete_organization!, only: [:destroy]
  before_filter :authorize_edit_organization!, only: [:update]
  def index
    @organizations = Organization.all
    render json: @organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations
  end

  def create
    @organization = @organization.children.new(params[:organization])
    if @organization.save
      render json: @organization, status: :created, serializer: AuthorizedOrganizationSerializer, root: :organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      render json: @organization, serializer: AuthorizedOrganizationSerializer, root: :organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.destroy if @organization.present?
    head :no_content
  end

  def authorized_users
    authorized_users = @organization.authorized_users
    render json: authorized_users, each_serializer: BasicUserSerializer, root: :authorized_users
  end

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
  def find_organization
    @organization = Organization.find(params[:id])
    return not_found! unless @organization
  end
  %W{create delete edit}.each do |action|
    define_method "authorize_#{action}_organization!" do
      return access_denied! unless can?(current_user, "#{action}_organization".to_sym, @organization)
    end
  end


end
