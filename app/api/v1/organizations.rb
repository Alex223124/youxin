class Organizations < Grape::API
  before { authenticate! }

  resource :organizations do
    route_param :id do
      before do
        @organization = Organization.find(params[:id])
      end
      get do
        present @organization, with: Youxin::Entities::OrganizationBasic
      end
      get 'members' do
        members = paginate @organization.members
        present members, with: Youxin::Entities::UserBasic
      end
      get 'receipts' do
        receipts = paginate current_user.receipts.from_organizations(@organization.id)
        present receipts, with: Youxin::Entities::Receipt
      end
      get 'unread_receipts' do
        unread_receipts = paginate current_user.receipts.from_organizations(@organization.id).unread
        present unread_receipts, with: Youxin::Entities::Receipt
      end
    end
  end
end