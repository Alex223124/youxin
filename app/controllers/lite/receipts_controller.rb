class Lite::ReceiptsController < Lite::ApplicationController
  def index
    @receipts = current_user.receipts
  end

  def show
    @receipt = current_user.receipts.where(id: params[:id]).first
    @post = @receipt.post
  end
end
