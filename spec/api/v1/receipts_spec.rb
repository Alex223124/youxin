require 'spec_helper'

describe Youxin::API, 'receipts' do
  include ApiHelpers
  before(:each) do
    @admin = create :user
    @user = create :user
    @user_another = create :user
    @organization = create :organization
    @actions_youxin = Action.options_array_for(:youxin)
    @actions_organization = Action.options_array_for(:organization)

    @organization.authorize_cover_offspring(@admin, @actions_youxin)
    @organization.push_member(@user)
    @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
  end
  describe "GET /receipts" do
    it "should return the array of receipts" do
      get api('/receipts', @user)
      @receipt = @user.receipts.first
      response.status.should == 200
      json_response.should == [
        {
          id: @receipt.id,
          read: @receipt.read,
          favorited: false,
          origin: @receipt.origin,
          organizations: [
            {
              id: @organization.id,
              name: @organization.name,
              created_at: @organization.created_at,
              avatar: @organization.avatar.url
            }
          ],
          post: {
            id: @receipt.post.id,
            title: @receipt.post.title,
            body: @receipt.post.body,
            body_html: @receipt.post.body_html,
            created_at: @receipt.post.created_at,
            attachments: [],
            forms: [],
            author: {
              id: @receipt.author.id,
              email: @receipt.author.email,
              name: @receipt.author.name,
              created_at: @receipt.author.created_at,
              avatar: @receipt.author.avatar.url,
              phone: @receipt.author.phone
            }
          }
        }
      ].as_json
    end
  end

  describe "GET /receipts/:id" do
    it "should return the receipt" do
      @receipt = @user.receipts.first
      get api("/receipts/#{@receipt.id}", @user)
      response.status.should == 200
      json_response.should == {
        id: @receipt.id,
        read: @receipt.read,
        favorited: false,
        origin: @receipt.origin,
        organizations: [
          {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          }
        ],
        post: {
          id: @receipt.post.id,
          title: @receipt.post.title,
          body: @receipt.post.body,
          body_html: @receipt.post.body_html,
          created_at: @receipt.post.created_at,
          attachments: [],
          forms: [],
          author: {
            id: @receipt.author.id,
            email: @receipt.author.email,
            name: @receipt.author.name,
            created_at: @receipt.author.created_at,
            avatar: @receipt.author.avatar.url,
            phone: @receipt.author.phone
          }
        }
      }.as_json
    end
    it "should return 404 when receipt not exist" do
      get api("/receipts/not_exist", @user)
      response.status.should == 404
    end
    it "should return 404 when receipt not belong to user" do
      @receipt = @user.receipts.first
      get api("/receipts/#{@receipt.id}", @user_another)
      response.status.should == 404
    end
  end

  describe "POST /receipts/:id/favorite" do
    it "should create favorite to receipt" do
      @receipt = @user.receipts.first
      post api("/receipts/#{@receipt.id}/favorite", @user)
      @favorite = @user.favorites.first
      response.status.should == 201
      json_response.should == {
        id: @receipt.id,
        read: true,
        favorited: true,
        origin: @receipt.origin,
        organizations: [
          {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          }
        ],
        post: {
          id: @receipt.post.id,
          title: @receipt.post.title,
          body: @receipt.post.body,
          body_html: @receipt.post.body_html,
          created_at: @receipt.post.created_at,
          attachments: [],
          forms: [],
          author: {
            id: @receipt.author.id,
            email: @receipt.author.email,
            name: @receipt.author.name,
            created_at: @receipt.author.created_at,
            avatar: @receipt.author.avatar.url,
            phone: @receipt.author.phone
          }
        }
      }.as_json
    end
    it "should return 400 " do
      @receipt = @user.receipts.first
      post api("/receipts/#{@receipt.id}/favorite", @user)
      post api("/receipts/#{@receipt.id}/favorite", @user)
      response.status.should == 400
      json_response['favoriteable_id'].should_not be_nil
    end
    it "should return 404" do
      @receipt = @user.receipts.first
      post api("/receipts/#{@receipt.id}/favorite", @user_another)
      response.status.should == 404
    end
  end

  describe "DELETE /receipts/:id/favorite" do
    it "should delete favorite to receipt" do
      @receipt = @user.receipts.first
      @receipt.favorites.create user_id: @user.id
      delete api("/receipts/#{@receipt.id}/favorite", @user)
      response.status.should == 204
    end
    it "should return 404" do
      @receipt = @user.receipts.first
      @receipt.favorites.create user_id: @user.id
      delete api("/receipts/#{@receipt.id}/favorite", @user_another)
      response.status.should == 404
    end
    it "should return 404" do
      @receipt = @user.receipts.first
      delete api("/receipts/#{@receipt.id}/favorite", @user)
      response.status.should == 404
    end
  end

  describe "PUT /receipts/:id/read" do
    it "should mark the receipt as read" do
      @receipt = @user.receipts.first
      put api("/receipts/#{@receipt.id}/read", @user)
      response.status.should == 204
    end
    it "should just return 204 when read" do
      @receipt = @user.receipts.first
      @receipt.read!
      put api("/receipts/#{@receipt.id}/read", @user)
      response.status.should == 204
    end
    it "should return 404" do
      @receipt = @user.receipts.first
      put api("/receipts/#{@receipt.id}/read", @user_another)
      response.status.should == 404
    end
    it "should return 404" do
      put api("/receipts/not_exist/read", @user)
      response.status.should == 404
    end
  end

end
