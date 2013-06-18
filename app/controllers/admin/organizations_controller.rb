class Admin::OrganizationsController < ApplicationController
  before_filter :find_organization, only: [:destroy]
  # TODO
  # create children, require parent
  # before_filter :authorize_create_organization!, only: [:new, :create]
  before_filter :authorize_delete_organization!, only: [:destroy]
  def new
    @organization = Organization.new
  end

  def index
    @organizations = Organization.all
  end

  def create
    @organization = Organization.new(params[:organization])

    respond_to do |format|
      if @organization.save
        format.html { redirect_to admin_organizations_path, notice: 'Organization was successfully created.' }
        format.json { render json: @organization, status: :created, location: @organization }
      else
        format.html { render 'new' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organization.destroy if @organization.present?
    redirect_to admin_organizations_path
  end

  private
  def find_organization
    @organization = Organization.find(params[:id])
  end
  %W{create delete}.each do |action|
    define_method "authorize_#{action}_organization!" do
      access_denied! unless can?(current_user, "#{action}_organization".to_sym, @organization)
    end
  end

end
