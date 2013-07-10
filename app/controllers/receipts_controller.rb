class ReceiptsController < ApplicationController
  before_filter :ensure_receipt, only: [:favorite, :unfavorite]
  # GET /receipts
  # GET /receipts.json
  def index
    @unread_receipts = current_user.receipts
    @read_receipts = current_user.receipts

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unread_receipts }
    end
  end

  def favorite
    favorite = @receipt.favorites.first_or_create user_id: current_user.id
    render nothing: true
  end
  def unfavorite
    favorite = @receipt.favorites.where(user_id: current_user.id).destroy_all
    render nothing: true
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    @receipt = Receipt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @receipt }
    end
  end

  # GET /receipts/new
  # GET /receipts/new.json
  def new
    @receipt = Receipt.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @receipt }
    end
  end

  # GET /receipts/1/edit
  def edit
    @receipt = Receipt.find(params[:id])
  end

  # POST /receipts
  # POST /receipts.json
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

  # PUT /receipts/1
  # PUT /receipts/1.json
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

  # DELETE /receipts/1
  # DELETE /receipts/1.json
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
