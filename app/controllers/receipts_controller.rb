class ReceiptsController < ApplicationController
  before_filter :ensure_receipt, only: [:favorite, :unfavorite]
  def index
  end
  def read
    @receipts = paginate current_user.receipts.read
    render json: @receipts
  end
  def unread
    @receipts = paginate current_user.receipts.unread
    render json: @receipts
  end

  def mark_as_read
    @receipt = current_user.receipts.where(id: params[:id]).first
    @receipt.read!
    render json: @receipt
  end

  def favorite
    favorite = @receipt.favorites.first_or_create user_id: current_user.id
    render nothing: true
  end
  def unfavorite
    favorite = @receipt.favorites.where(user_id: current_user.id).destroy_all
    render nothing: true
  end

  def show
    @receipt = Receipt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @receipt }
    end
  end

  def new
    @receipt = Receipt.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @receipt }
    end
  end

  def edit
    @receipt = Receipt.find(params[:id])
  end

  def create
    @receipt = Receipt.new(params[:receipt])

    respond_to do |format|
      if @receipt.save
        format.html { redirect_to @receipt, notice: 'Receipt was successfully created.' }
        format.json { render json: @receipt, status: :created, location: @receipt }
      else
        format.html { render action: "new" }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @receipt = Receipt.find(params[:id])

    respond_to do |format|
      if @receipt.update_attributes(params[:receipt])
        format.html { redirect_to @receipt, notice: 'Receipt was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @receipt = Receipt.find(params[:id])
    @receipt.destroy

    respond_to do |format|
      format.html { redirect_to receipts_url }
      format.json { head :no_content }
    end
  end

  private
  def ensure_receipt
    @receipt = current_user.receipts.where(id: params[:id]).first
    access_denied! unless @receipt
  end
end
