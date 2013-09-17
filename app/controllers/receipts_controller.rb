class ReceiptsController < ApplicationController
  before_filter :ensure_receipt, only: [:read, :favorite, :unfavorite, :show]
  skip_before_filter :authenticate_user!, only: [:mobile_show, :mobile_collection_create]
  before_filter :ensure_receipt_by_short_key, only: [:mobile_show, :mobile_collection_create]
  before_filter :ensure_form, only: [:mobile_collection_create]
  before_filter :ensure_blank_collection, only: [:mobile_collection_create]

  def index
    @receipts = filtered_receipts
    render json: @receipts
  end

  def show
    render json: @receipt, root: :receipt
  end

  def mobile_show
    @receipt.read!
    @post = @receipt.post
    @form = @post.forms.first
    render layout: false
  end
  def mobile_collection_create
    entities = params[:collection]
    collection = @form.collections.new(Collection.clean_attributes_with_entities(entities, @form).merge({ user_id: @receipt.user_id }))
    if collection.save
      flash[:notice] = '表单提交成功'
      redirect_to mobile_receipt_path(@receipt.short_key)
    else
      flash[:error] = "错误：#{collection.errors.full_messages.join(', ')}"
      redirect_to mobile_receipt_path(@receipt.short_key)
    end
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
    raise Youxin::NotFound.new('优信') unless @receipt
  end
  def filtered_receipts
    case params[:status]
    when 'read' then paginate current_user.receipts.read
    when 'unread' then range current_user.receipts.unread
    else paginate current_user.receipts
    end
  end
  def ensure_receipt_by_short_key
    @receipt = Receipt.where(short_key: params[:short_key]).first
    raise Youxin::NotFound.new('优信') unless @receipt
  end
  def ensure_form
    @receipt = Receipt.where(short_key: params[:short_key]).first
    raise Youxin::NotFound.new('优信') unless @receipt
    @form = @receipt.post.forms.first
    raise Youxin::NotFound.new('表单') unless @form
  end
  def ensure_blank_collection
    raise Youxin::InvalidParameters.new('表单已经提交过了') if @receipt.forms_filled?
  end
end
