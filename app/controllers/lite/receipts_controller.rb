# encoding: utf-8

class Lite::ReceiptsController < Lite::ApplicationController
  before_filter :ensure_receipt, only: [:show]

  def index
    @receipts = paginate current_user.receipts.unscoped.asc(:read).desc(:_id)
  end

  def show
    @receipt.read!
    @post = @receipt.post
  end

  private
  def ensure_receipt
    @receipt = current_user.receipts.where(id: params[:id]).first
    raise Youxin::NotFound.new('优信') unless @receipt
  end
end
