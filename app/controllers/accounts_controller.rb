class AccountsController < ApplicationController
  def organizations
    organizations = current_user.organizations
    render json: organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations
  end
  def authorized_organizations
    actions = params[:actions]
    if actions.present?
      authorized_organizations = current_user.authorized_organizations(actions)
    else
      authorized_organizations = current_user.authorized_organizations
    end

    render json: authorized_organizations, each_serializer: AuthorizedOrganizationSerializer, root: :authorized_organizations
  end
  def recent_authorized_organizations
    recent_authorized_organizations = {
      organization_ids: current_user.authorized_organizations.map(&:id),
      organization_clan_ids: []
    }
    render json: { recent_authorized_organizations: recent_authorized_organizations }
  end

  def update
    if current_user.update_attributes params[:user]
      head :no_content
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: current_user, serializer: UserSerializer, root: :user
  end

  def created_receipts
    created_receipts = current_user.receipts.where(origin: true)
    render json: created_receipts, serialize: ReceiptSerializer, root: :created_receipts
  end
  def favorited_receipts
    favorited_receipts = current_user.favorites.receipts.map(&:favoriteable)
    render json: favorited_receipts, serialize: ReceiptSerializer, root: :favorited_receipts
  end
end