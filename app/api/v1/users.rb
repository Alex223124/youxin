class Users < Grape::API
  before { authenticate! }

  resource :user do
    desc 'Get the info of current user.'
    get do
      present current_user, with: Youxin::Entities::User
    end

    desc 'Get organizations which the user have the authorization in.'
    get 'authorized_organizations' do
      actions = attributes_for_keys([:actions])[:actions]
      if actions
        actions = actions.map(&:to_sym)
        authorized_organizations = []
        relationships = current_user.user_actions_organization_relationships
        relationships.each do |relationship|
          authorized_organizations << relationship.organization if actions - relationship.actions == []
        end
      else
        authorized_organizations = current_user.authorized_organizations
      end

      present authorized_organizations, with: Youxin::Entities::AuthorizedOrganization
    end

    desc 'Get recent organizations who have sent post to user'
    get 'receipt_organizations' do
      receipt_organizations = current_user.receipt_organizations
      present receipt_organizations, with: Youxin::Entities::ReceiptOrganization, current_user: current_user
    end

    desc 'Get recent contacts who have sent post to user'
    get 'receipt_users' do
      receipt_users = current_user.receipt_users
      present receipt_users, with: Youxin::Entities::ReceiptUser, current_user: current_user
    end

    desc 'Get all the receipts.'
    get 'receipts' do
      receipts = paginate current_user.receipts
      present receipts, with: Youxin::Entities::Receipt
    end
    desc 'Get all the unread receipts.'
    get 'unread_receipts' do
      receipts = paginate current_user.receipts.unread
      present receipts, with: Youxin::Entities::Receipt
    end

    desc 'Get all the favorite receipts'
    get 'favorite_receipts' do
      receipts = paginate(current_user.favorites.receipts).map(&:favoriteable)
      present receipts, with: Youxin::Entities::Receipt
    end
  end

  resource :users do
    route_param :id do
      before do
        @user = User.find(params[:id])
      end
      get do
        present @user, with: Youxin::Entities::User
      end
      get 'organizations' do
        organizations = @user.organizations
        present organizations, with: Youxin::Entities::OrganizationBasic
      end
      get 'receipts' do
        receipts = paginate current_user.receipts.from_users(@user.id)
        present receipts, with: Youxin::Entities::Receipt
      end
      get 'unread_receipts' do
        unread_receipts = paginate current_user.receipts.from_users(@user.id).unread
        present unread_receipts, with: Youxin::Entities::Receipt
      end
    end
  end

end