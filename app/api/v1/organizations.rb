class Organizations < Grape::API
  before { authenticate! }

  resource :organizations do
    get do
      organizations = current_namespace.organizations
      present organizations, with: Youxin::Entities::Organization
    end
    route_param :id do
      before do
        @organization = current_namespace.organizations.find(params[:id])
      end
      get do
        present @organization, with: Youxin::Entities::OrganizationWithProfile, current_user: current_user
      end
      put do
        authorize! :edit_organization, @organization
        attrs = attributes_for_keys [:avatar, :bio, :header, :name]
        if @organization.update_attributes attrs
          status(204)
        else
          fail!(@organization.errors)
        end
      end
      get 'members' do
        members = @organization.members
        if members.include?(current_user) || current_user.authorized_organizations.include?(@organization)
          present members, with: Youxin::Entities::UserBasic
        else
          present members, with: Youxin::Entities::UserSimple
        end
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
        present children, with: Youxin::Entities::Organization
      end
      get 'authorized_users' do
        authorized_users = @organization.authorized_users
        present authorized_users, with: Youxin::Entities::AuthorizedUser, organization: @organization
      end
    end
  end
end
