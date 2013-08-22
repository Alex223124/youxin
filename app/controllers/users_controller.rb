# encoding: utf-8

class UsersController < ApplicationController
  before_filter :ensure_user!, only: [:organizations, :authorized_organizations, :update, :show, :created_receipts]
  before_filter :authorize_edit_members!, only: [:update]

  def organizations
    organizations = @user.organizations
    render json: organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations
  end

  def authorized_organizations
    actions = params[:actions]
    if actions.present?
      authorized_organizations = @user.authorized_organizations(actions)
    else
      authorized_organizations = @user.authorized_organizations
    end

    render json: authorized_organizations, each_serializer: AuthorizedOrganizationSerializer, root: :authorized_organizations
  end

  def update
    if @user.update_attributes params[:user]
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @user, serializer: UserSerializer, root: :user
  end

  def created_receipts
    if current_user == @user
      created_receipts = current_user.receipts.where(origin: true)
    else
      created_receipts = current_user.receipts.from_user(@user)
    end
    render json: created_receipts, serialize: ReceiptSerializer, root: :created_receipts
  end

  private
  def ensure_user!
    @user = current_namespace.users.where(id: params[:id]).first
    raise Youxin::NotFound.new('用户') unless @user
  end
  def authorize_edit_members!
    return if current_user == @user
    raise Youxin::Forbidden if current_user.authorized_organizations([:edit_member]).select { |organization| @user.organizations.include?(organization) }.blank?
  end
end