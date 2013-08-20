class ReceiptsController < ApplicationController
  before_filter :ensure_receipt, only: [:read, :favorite, :unfavorite]
  def index
    @receipts = filtered_receipts
    render json: @receipts
  end

  def read
    @receipt.read!
    head(204)
  end

  def favorite
    favorite = @receipt.favorites.first_or_create user_id: current_user.id
    head(201)
  end
  def unfavorite
    favorite = @receipt.favorites.where(user_id: current_user.id).destroy_all
    head(204)
  end

  private
  def ensure_receipt
    @receipt = current_user.receipts.where(id: params[:id]).first
    raise Youxin::NotFound unless @receipt
  end
  def filtered_receipts
    case params[:status]
    when 'read' then paginate current_user.receipts.read
    when 'unread' then range current_user.receipts.unread
    else paginate current_user.receipts
    end
  end
end
