class Receipts < Grape::API
  before { authenticate! }

  resource :receipts do
    get do
      present current_user.receipts, with: Youxin::Entities::Receipt
    end
  end
end