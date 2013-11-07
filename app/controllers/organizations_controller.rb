class OrganizationsController < ApplicationController
  before_filter :ensure_organization, only: [:create_children, :update, :destroy, :authorized_users, :receipts, :export_users]
  before_filter :authorize_create_organization!, only: [:create_children]
  before_filter :authorize_delete_organization!, only: [:destroy]
  before_filter :authorize_edit_organization!, only: [:update, :export_users]
  def index
    @organizations = current_namespace.organizations.all
    render json: @organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations
  end

  # FIXME: authorize the new child, when create new child
  def create_children
    @organization = @organization.children.new(params[:organization])
    @organization.namespace = current_namespace
    if @organization.save
      render json: @organization, status: :created, serializer: AuthorizedOrganizationSerializer, root: :organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      render json: @organization, serializer: AuthorizedOrganizationSerializer, root: :organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @organization.destroy
    head :no_content
  end

  def authorized_users
    authorized_users = @organization.authorized_users
    render json: authorized_users, each_serializer: BasicUserSerializer, root: :authorized_users
  end

  def receipts
    receipts = current_user.receipts.from_organization(@organization)
    render json: receipts, serialize: ReceiptSerializer, root: :receipts
  end

  def members
    members = current_namespace.users
    render json: members, each_serializer: BasicUserSerializer, root: :members
  end

  def export_users
    options = params[:selected_options] || []
    offspring = params[:offspring_selected] || false
    users = if offspring
               ([@organization] + @organization.offspring).map(&:members).flatten
            else
              users = @organization.members
            end
    valid_options = []
    options.each do |option|
      User.instance_methods.include? option.to_sym
      valid_options.push option
    end
    file = export(users, valid_options)
    send_file file.path, filename: "#{@organization.name}.xls", type: 'application/vnd.ms-excel; charset=utf-8', disposition: 'attachment'
  end

  private
  def ensure_organization
    @organization = current_namespace.organizations.where(id: params[:id]).first
    raise Youxin::NotFound unless @organization
  end

  def export(users, options)
    file = Tempfile.new('/tmp/export_users', Rails.root)
    book = WriteExcel.new file.path
    sheet = book.add_worksheet
    format_bold = book.add_format
    format_bold.set_bold

    labels = User.human_options(options)
    sheet.write 'A1', labels, format_bold

    users.each_with_index do |user, index|
      values = user.archive(options)
      sheet.write "A#{index + 2}", values
    end
    book.close
    file
  end

end
