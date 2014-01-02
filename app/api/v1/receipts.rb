class Receipts < Grape::API
  before { authenticate! }

  resource :receipts do
    get do
      receipts = paginate current_user.receipts.unarchived
      present receipts, with: Youxin::Entities::Receipt
    end
    put :read do
      receipts = current_user.receipts.where(:id.in => params[:receipt_ids])
      receipts.map { |receipt| receipt.read! }
      status(204)
    end
    route_param :id do
      before do
        @receipt = current_user.receipts.find(params[:id])
        not_found!("receipt") unless @receipt
      end
      get do
        present @receipt, with: Youxin::Entities::Receipt
      end
      post 'favorite' do
        favorite = @receipt.favorites.new user_id: current_user.id
        if favorite.save
          present @receipt, with: Youxin::Entities::Receipt
        else
          fail!(favorite.errors)
        end
      end
      delete 'favorite' do
        favorite = @receipt.favorites.find_by(user_id: current_user.id)
        not_found!("favorite") unless favorite
        favorite.destroy
        status(204)
      end
      put 'read' do
        @receipt.read!
        status(204)
      end
      put :archived do
        @receipt.archive!
        status(204)
      end
      delete :archived do
        @receipt.unarchive!
        status(204)
      end
    end
  end
end
