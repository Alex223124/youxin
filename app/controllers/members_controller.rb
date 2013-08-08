# encoding: utf-8

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

  def import
    initial_position = Position.where(name: '学生').first
    begin
      excel_praser = Youxin::ExcelPraser.new(params[:file].tempfile)
    rescue Youxin::ExcelPraser::InvalidFileType => e
      return bad_request!
    end
    excel_praser.process
    fail_users = Array.new
    created_users = Array.new
    excel_praser.user_array.each do |user_attr|
      password = Devise.friendly_token.first(8)
      attrs = user_attr.merge({ password: password, password_confirmation: password })
      user = User.new attrs
      if user.save
        # TODO: need asyn
        user.send_reset_password_instructions
        created_users.push user
        @organization.push_member(user, initial_position)
      else
        user_attr[:errors] = user.errors.keys
        fail_users.push user_attr
      end
    end
    render json: created_users, each_serializer: MemberSerializer, root: :members, meta: { fail_members: fail_users }
  end

  def create
    attrs = params[:user]
    password = Devise.friendly_token.first(8)
    attrs.merge!({ password: password, password_confirmation: password })
    initial_position = Position.where(name: '学生').first
    user = User.new attrs
    if user.save
      # TODO: need asyn
      user.send_reset_password_instructions
      @organization.push_member(user, initial_position)
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
