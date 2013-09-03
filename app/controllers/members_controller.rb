# encoding: utf-8

class MembersController < ApplicationController
  before_filter :ensure_organization!
  before_filter :authorize_add_member!, only: [:create, :import, :update, :update_role]
  before_filter :authorize_remove_member!, only: [:destroy, :destroy_role]
  before_filter :prepare_members, only: [:update, :destroy, :update_role, :destroy_role]

  serialization_scope :organization

  def index
    members = @organization.members
    if @organization.members.include?(current_user) || @organization.authorized_users.include?(current_user)
      render json: members, each_serializer: MemberSerializer, root: :members
    else
      render json: members, each_serializer: OtherMemberSerializer, root: :members
    end
  end

  def create
    attrs = params[:member]
    password = Devise.friendly_token.first(8)
    attrs.merge!({ password: password, password_confirmation: password })
    member = current_namespace.users.new attrs
    if member.save
      @organization.push_member(member)
      # TODO: need async
      member.send_welcome_instructions
      render json: member, status: :created, serializer: MemberSerializer
    else
      render json: member.errors, status: :unprocessable_entity
    end
  end

  def import
    begin
      excel_praser = Youxin::ExcelPraser.new(params[:file].tempfile)
    rescue
      raise Youxin::InvalidParameters.new('上传文件')
    end
    excel_praser.process
    unimported_members = Array.new
    created_members = Array.new
    excel_praser.user_array.each do |member_attr|
      password = Devise.friendly_token.first(8)
      attrs = member_attr.merge({ password: password, password_confirmation: password })
      member = current_namespace.users.new attrs
      if member.save
        # TODO: need asyn
        member.send_welcome_instructions
        created_members.push member
        @organization.push_member(member)
      else
        member_attr[:errors] = member.errors.keys
        unimported_members.push member_attr
      end
    end
    render json: created_members, each_serializer: MemberSerializer, root: :members, meta: { unimported_members: unimported_members }
  end

  def update
    position = current_namespace.positions.where(id: params[:position_id]).first
    @organization.push_members(@members, position)
    render json: @members, each_serializer: MemberSerializer, root: :members
  end
  def destroy
    @organization.pull_members(@members)
    head :no_content
  end

  def update_role
    role = current_namespace.roles.where(id: params[:role_id]).first
    raise Youxin::NotFound.new('权限') unless role
    @members.each do |member|
      relationship = member.user_role_organization_relationships.where(organization_id: @organization.id).first_or_initialize
      relationship.role = role
      relationship.save
    end
    head :no_content
  end
  def destroy_role
    @members.each do |member|
      relationship = member.user_role_organization_relationships.where(organization_id: @organization.id).first
      relationship.destroy if relationship
    end
    head :no_content
  end

  private
  def organization
    @organization
  end
  def ensure_organization!
    @organization = current_namespace.organizations.where(id: params[:organization_id]).first
    raise Youxin::NotFound.new('组织') unless @organization
  end
  def prepare_members
    raise Youxin::InvalidParameters.new('成员') unless params[:member_ids].is_a?(Array)
    @members = current_namespace.users.where(:id.in => params[:member_ids])
    raise Youxin::NotFound if @members.blank?
  end
end
