class MembersController < ApplicationController
  before_filter :find_organization
  before_filter :authorize_add_member!, only: [:update]
  before_filter :authorize_remove_member!, only: [:destroy]
  before_filter :ensure_members, only: [:update, :destroy]

  serialization_scope :organization
  def index
    members = @organization.members
    render json: members, each_serializer: MemberSerializer, root: :members
  end

  def update
    @organization.push_members(@members)
    render json: @members, each_serializer: MemberSerializer, root: :members    
  end

  def destroy
    @organization.pull_members(@members)
    render json: @members, each_serializer: MemberSerializer, root: :members
  end

  private
  def organization
    @organization
  end
  def find_organization
    @organization = Organization.where(id: params[:id]).first
    not_found! unless @organization
  end

  %W{add remove}.each do |action|
    define_method "authorize_#{action}_member!" do
      access_denied! unless can?(current_user, "#{action}_member".to_sym, @organization)
    end
  end

  def ensure_members
    @members = User.where(params[:member_ids])
    return not_found! if @members.blank?
  end
end
