class Admin::MembersController < ApplicationController
  before_filter :find_organization
  def index
  end

  def update
    @organization.push_members(params[:member_ids])
    redirect_to members_admin_organization_path(@organization)
  end

  def destroy
    @organization.pull_members(params[:member_ids])
    redirect_to members_admin_organization_path(@organization)
  end

  private
  def find_organization
    @organization = Organization.where(id: params[:id]).first
    redirect_to :back, flash: { alert: 'Organization does not exist' } unless @organization
  end
end
