class Admin::OrganizationsController < Admin::ApplicationController
  before_filter :ensure_organization!

  def show
  end

  private
  def ensure_organization!
    @organization = Organization.where(id: params[:id]).first
    raise Youxin::NotFound.new('organization') unless @organization
  end
end
