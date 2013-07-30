require 'spec_helper'

describe Youxin::API, 'organizations' do
  include ApiHelpers

  describe "GET /organizations" do
    before(:each) do
      @organization_one = create :organization
      @organization_another = create :organization, parent: @organization_one
      @user = create :user
    end
    it "should return the array of organizations" do
      get api('/organizations', @user)
      response.status.should == 200
      json_response.should == [
        {
          id: @organization_one.id,
          name: @organization_one.name,
          created_at: @organization_one.created_at,
          avatar: @organization_one.avatar.url,
          parent_id: @organization_one.parent_id,
          members: @organization_one.members.count
        },
        {
          id: @organization_another.id,
          name: @organization_another.name,
          created_at: @organization_another.created_at,
          avatar: @organization_another.avatar.url,
          parent_id: @organization_another.parent_id,
          members: @organization_another.members.count
        }
      ].as_json
    end
  end

  describe "PUT /organizations/:id" do
    before(:each) do
      @organization = create :organization
      @user = create :user
    end
    context "success" do
      before(:each) do
        actions = Action.options_array
        @organization.authorize(@user, actions)
      end
      it "should update name" do
        expect do
          put api("/organizations/#{@organization.id}", @user), { name: 'new-name' }
        end.to change { @organization.name }
      end
      it "should update header" do
        header_path = Rails.root.join("spec/factories/images/header/header1.png")
        header = Rack::Test::UploadedFile.new(header_path, 'image/png')
        expect do
          put api("/organizations/#{@organization.id}", @user), { header: header }
          @organization.reload
        end.to change { @organization.header.url }
        response.status.should == 204
      end
      it "should update avatar" do
        avatar_path = Rails.root.join("spec/factories/images/avatar/avatar1.jpg")
        avatar = Rack::Test::UploadedFile.new(avatar_path, 'image/jpg')
        expect do
          put api("/organizations/#{@organization.id}", @user), { avatar: avatar }
          @organization.reload
        end.to change { @organization.avatar.url }
        response.status.should == 204
      end
    end
    it "should return 403" do
      put api("/organizations/#{@organization.id}", @user), { name: 'new-name' }
      response.status.should == 403
    end
  end

  describe "GET /organizations/:id" do
    before(:each) do
      @user = create :user
      @author = create :user
      @organization = create :organization
      @organization.push_member(@user)
    end
    context "/" do
      it "should return single organization" do
        actions = Action.options_array
        @organization.authorize(@user, actions)
        get api("/organizations/#{@organization.id}", @user)
        response.status.should == 200
        json_response.should == {
          id: @organization.id,
          name: @organization.name,
          created_at: @organization.created_at,
          avatar: @organization.avatar.url,
          header: @organization.header.url,
          bio: @organization.bio,
          authorized_users: [
            {
              id: @user.id,
              name: @user.name,
              avatar: @user.avatar.url
            }
          ]
        }.as_json
      end
    end

    context "/members" do
      it "should return the members of single organization" do
        @user_another = create :user
        @organization.push_members([@user, @user_another])
        get api("/organizations/#{@organization.id}/members", @user)
        response.status.should == 200
        json_response.should == [
          {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            created_at: @user.created_at,
            avatar: @user.avatar.url,
            phone: @user.phone
          },
          {
            id: @user_another.id,
            email: @user_another.email,
            name: @user_another.name,
            created_at: @user_another.created_at,
            avatar: @user_another.avatar.url,
            phone: @user_another.phone
          }
        ].as_json
      end
    end

    context "/receipts" do
      it "should return the receipts from single organization" do
        post = create :post, author: @author, organization_ids: [@organization].map(&:id)
        @receipt = @user.receipts.first
        get api("/organizations/#{@organization.id}/receipts", @user)
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

    context "/unread_receipts" do
      it "should return the unread receipts from single organization" do
        post_1 = create :post, author: @author, organization_ids: [@organization].map(&:id)
        post_2 = create :post, author: @author, organization_ids: [@organization].map(&:id)
        @receipt_1 = post_1.receipts.where(user_id: @user.id).first
        @receipt_2 = post_2.receipts.where(user_id: @user.id).first
        @receipt_1.read!
        get api("/organizations/#{@organization.id}/unread_receipts", @user)
        response.status.should == 200
        json_response.should == [
          id: @receipt_2.id,
          read: @receipt_2.read,
          favorited: false,
          origin: @receipt_2.origin,
          organizations: [
            {
              id: @organization.id,
              name: @organization.name,
              created_at: @organization.created_at,
              avatar: @organization.avatar.url
            }
          ],
          post: {
            id: @receipt_2.post.id,
            title: @receipt_2.post.title,
            body: @receipt_2.post.body,
            body_html: @receipt_2.post.body_html,
            created_at: @receipt_2.post.created_at,
            attachments: [],
            forms: [],
            author: {
              id: @receipt_2.author.id,
              email: @receipt_2.author.email,
              name: @receipt_2.author.name,
              created_at: @receipt_2.author.created_at,
              avatar: @receipt_2.author.avatar.url,
              phone: @receipt_2.author.phone
            }
          }
        ].as_json
      end
    end

    context "/children" do
      before(:each) do
        @organization_one = create :organization, parent: @organization
        @organization_another = create :organization, parent: @organization
      end
      it "should return children of the organization" do
        get api("/organizations/#{@organization.id}/children", @user)
        json_response.should == [
          {
            id: @organization_one.id,
            name: @organization_one.name,
            created_at: @organization_one.created_at,
            avatar: @organization_one.avatar.url,
            bio: nil,
            authorized_users: []
          },
          {
            id: @organization_another.id,
            name: @organization_another.name,
            created_at: @organization_another.created_at,
            avatar: @organization_another.avatar.url,
            bio: nil,
            authorized_users: []
          }
        ].as_json
      end
    end

    context "/authorized_users" do
      before(:each) do
        @actions = Action.options_array
        @organization_one = create :organization, parent: @organization
        @organization.authorize_cover_offspring(@user, @actions)
        @organization.reload
        @organization_one.reload
      end
      it "should return authorized_users" do
        get api("/organizations/#{@organization.id}/authorized_users", @user)
        json_response.should == [
          {
            id: @user.id,
            name: @user.name,
            avatar: @user.avatar.url,
            actions: @actions
          }
        ].as_json
      end
      it "should return authorized_users when authorize_cover_offspring" do
        get api("/organizations/#{@organization_one.id}/authorized_users", @user)
        json_response.should == [
          {
            id: @user.id,
            name: @user.name,
            avatar: @user.avatar.url,
            actions: @actions
          }
        ].as_json
      end
    end

  end
end