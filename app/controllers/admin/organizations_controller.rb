class Admin::OrganizationsController < ApplicationController
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
        format.html { render action: "new" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy if @organization.present?
    redirect_to admin_organizations_path
  end
end
