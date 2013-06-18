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
        present @organization.members, with: Youxin::Entities::UserBasic
      end
      get 'receipts' do
        receipts = current_user.receipts.from_organizations(@organization.id)
        present receipts, with: Youxin::Entities::Receipt
      end
      get 'unread_receipts' do
        unread_receipts = current_user.receipts.from_organizations(@organization.id).unread
        present unread_receipts, with: Youxin::Entities::Receipt
      end
    end
  end
end