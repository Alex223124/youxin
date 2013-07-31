class Organizations < Grape::API
  before { authenticate! }

  resource :organizations do
    route_param :id do
      before do
        @organization = Organization.find(params[:id])
      end
      get do
        present @organization, with: Youxin::Entities::OrganizationWithAuthorizedUsersAndProfile
      end
      put do
        authorize! :edit_organization, @organization
        attrs = attributes_for_keys [:avatar, :header, :name]
        if @organization.update_attributes attrs
          status(204)
        else
          fail!(@organization.errors)
        end
      end
      get 'members' do
        members = paginate @organization.members
        present members, with: Youxin::Entities::UserBasic
      end
      get 'receipts' do
        receipts = paginate current_user.receipts.from_organization(@organization)
        present receipts, with: Youxin::Entities::Receipt
      end
      get 'unread_receipts' do
        unread_receipts = paginate current_user.receipts.from_organization(@organization).unread
        present unread_receipts, with: Youxin::Entities::Receipt
      end
      get 'children' do
        children = @organization.children
        present children, with: Youxin::Entities::OrganizationWithAuthorizedUsers
      end
      get 'authorized_users' do
        authorized_users = @organization.authorized_users
        present authorized_users, with: Youxin::Entities::AuthorizedUser, organization: @organization
      end
    end
  end
end