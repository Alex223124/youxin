require 'spec_helper'

describe ReceiptsController do
  include JsonParser

  before(:each) do
    @user = create :user
    sign_in @user

    @admin = create :user
    @organization = create :organization
    @actions_youxin = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@admin, @actions_youxin)
    @organization.push_member(@user)
  end
  describe "GET index" do
    before(:each) do
      3.times do
        create :post, author: @admin, organization_ids: [@organization].map(&:id)
      end
    end
    it "returns http success" do
      get 'index'
      response.should be_success
    end
    it "should return the array of receipts of current user" do
      get 'index'
      json_response.should have_key('receipts')
      json_response['receipts'].size.should == 3
    end
    it "should return unread receipts of current" do
      2.times { @user.receipts.unread.first.read! }
      get 'index', status: :unread
      json_response.should have_key('receipts')
      json_response['receipts'].size.should == 1
    end
    it "should return read receipts of current user" do
      2.times { @user.receipts.unread.first.read! }
      get 'index', status: :read
      json_response.should have_key('receipts')
      json_response['receipts'].size.should == 2
    end
  end
  describe "PUT read" do
    before(:each) do
      3.times do
        create :post, author: @admin, organization_ids: [@organization].map(&:id)
      end
      @user_another = create :user
      @organization_another = create :organization
      @organization_another.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_another.push_member(@user_another)

      @post_another = create :post, author: @admin, organization_ids: [@organization_another].map(&:id)
    end
    it "should mark the receipt as read" do
      receipt = @user.receipts.first
      expect do
        put :read, id: receipt.id
        receipt.reload
      end.to change { receipt.read_at }
      response.status.should == 204
    end
    it "should return 404 if receipt doesnt exist" do
      put :read, id: :not_exists
      response.status.should == 404
    end
    it "should return 404 if receipt doesnt exist" do
      receipt = @post_another.receipts.where(user_id: @user_another.id).first
      put :read, id: receipt.id
      response.status.should == 404
    end
  end
  describe "PUT /favorite" do
    before(:each) do
      create :post, author: @admin, organization_ids: [@organization].map(&:id)

      @user_another = create :user
      @organization_another = create :organization
      @organization_another.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_another.push_member(@user_another)

      @post_another = create :post, author: @admin, organization_ids: [@organization_another].map(&:id)
    end
    it "should return 201" do
      receipt = @user.receipts.first
      post :favorite, id: receipt.id
      response.status.should == 201
    end
    it "should favorite the receipt" do
      receipt = @user.receipts.first
      post :favorite, id: receipt.id
      receipt.favorites.count.should == 1
      @user.favorites.receipts.count.should == 1
    end
    it "should return 404 if receipt doesnt exist" do
      post :favorite, id: :not_exists
      response.status.should == 404
    end
    it "should return 404 if receipt doesnt exist" do
      receipt = @post_another.receipts.where(user_id: @user_another.id).first
      post :favorite, id: receipt.id
      response.status.should == 404
    end
  end
  describe "DELETE /favorite" do
    before(:each) do
      create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @receipt = @user.receipts.first
      favorite = @receipt.favorites.first_or_create user_id: @user.id
    end
    it "should return 204" do
      delete :unfavorite, id: @receipt.id
      response.status.should == 204
    end
    it "should unfavorite the receipt" do
      expect do
        delete :unfavorite, id: @receipt.id
      end.to change { @user.favorites.receipts.count }.by(-1)
    end
  end
end
