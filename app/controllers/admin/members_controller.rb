class Admin::MembersController < ApplicationController
  before_filter :find_organization
  before_filter :authorize_add_member!, only: [:update]
  before_filter :authorize_remove_member!, only: [:destroy]
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

  %W{add remove}.each do |action|
    define_method "authorize_#{action}_member!" do
      access_denied! unless can?(current_user, "#{action}_member".to_sym, @organization)
    end
  end
end
