class MembersController < ApplicationController
  before_filter :find_organization
  before_filter :authorize_add_member!, only: [:update], if: :is_put_method
  before_filter :authorize_add_member!, only: [:create]
  before_filter :authorize_remove_member!, only: [:update], if: :is_delete_method
  before_filter :ensure_members, only: [:update]

  serialization_scope :organization
  def index
    members = @organization.members
    render json: members, each_serializer: MemberSerializer, root: :members
  end

  def update
    if is_put_method
      position = Position.where(params[:position_id]).first
      @organization.push_members(@members, position)
      render json: @members, each_serializer: MemberSerializer, root: :members
    elsif is_delete_method      
      @organization.pull_members(@members)
      head :no_content
    else
      render nothing: true, status: :unprocessable_entity 
    end
  end

  def create
    attrs = params[:user]
    password = Devise.friendly_token.first(8)
    email = "#{password}@combee.com"
    attrs.merge!({ password: password, password_confirmation: password, email: email })
    user = User.new attrs
    if user.save
      @organization.push_member(user)
      render json: user, status: :created, serializer: MemberSerializer
    else
      render json: user.errors, status: :unprocessable_entity 
    end
  end

  private
  def organization
    @organization
  end
  def is_put_method
    params[:method] == 'put'
  end
  def is_delete_method
    params[:method] == 'delete'
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
    return not_found! unless params[:member_ids].is_a?(Array)
    @members = User.where(:id.in => params[:member_ids])
    return not_found! if @members.blank?
  end
end
