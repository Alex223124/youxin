# encoding: utf-8

require 'spec_helper'

describe Youxin::API, 'users' do
  include ApiHelpers

  let(:namespace) { create :namespace }

  describe "GET /user" do
    before(:each) do
      @user = create :user, namespace: namespace
    end
    it "should return current user" do
      get api('/user', @user)
      response.status.should == 200
      json_response['email'].should == @user.email
      json_response['name'].should == @user.name
    end
    it "should return 401" do
      get api('/user')
      response.status.should == 401
    end
  end

  describe "PUT /user" do
    before(:each) do
      @user = create :user, namespace: namespace
    end
    context "header" do
      before(:each) do
        header_path1 = Rails.root.join("spec/factories/images/header/header1.png")
        @header1 = Rack::Test::UploadedFile.new(header_path1, 'image/png')
        header_path2 = Rails.root.join("spec/factories/images/header/header2.png")
        @header2 = Rack::Test::UploadedFile.new(header_path2, 'image/png')
      end
      it "should update header of current user" do
        expect do
          put api('/user', @user), { header: @header1 }
          @user.reload
        end.to change { @user.header.url }
        response.status.should == 204
      end
      it "should update header" do
        pending 'should change header again'
        @user.update_attributes header: @header1
        @user.reload
        expect do
          put api('/user', @user), { header: @header2 }
          @user.reload
        end.to change { @user.header.url }
        response.status.should == 204
      end
    end
    context "avatar" do
      before(:each) do
        avatar_path1 = Rails.root.join("spec/factories/images/avatar/avatar1.jpg")
        @avatar1 = Rack::Test::UploadedFile.new(avatar_path1, 'image/jpg')
        avatar_path2 = Rails.root.join("spec/factories/images/avatar/avatar2.jpg")
        @avatar2 = Rack::Test::UploadedFile.new(avatar_path2, 'image/jpg')
      end
      it "should update avatar of current user" do
        expect do
          put api('/user', @user), { avatar: @avatar1 }
          @user.reload
        end.to change { @user.avatar.url }
        response.status.should == 204
      end
      it "should update avatar" do
        pending 'should change avatar again'
        @user.update_attributes avatar: @avatar1
        @user.reload
        expect do
          put api('/user', @user), { avatar: @avatar2 }
          @user.reload
        end.to change { @user.avatar.url }
        response.status.should == 204
      end
    end
    it "should update name" do
      expect do
        put api('/user', @user), { name: 'new-name' }
        @user.reload
      end.to change { @user.name }
    end
    it "should update phone" do
      expect do
        put api('/user', @user), { phone: '18700000000' }
        @user.reload
      end.to change { @user.phone }
    end
    it "should update bio" do
      expect do
        put api('/user', @user), { bio: 'new-bio' }
        @user.reload
      end.to change { @user.bio }
    end
    it "should update gender" do
      expect do
        put api('/user', @user), { gender: '男' }
        @user.reload
      end.to change { @user.gender }
    end
    context 'qq' do
      before(:each) do
        @user.qq = '123456789'
        @user.save
      end
      it "should update qq" do
        expect do
          put api('/user', @user), { qq: '12345' }
          @user.reload
        end.to change { @user.qq }
      end
    end
    context 'email' do
      it 'should update email' do
        expect do
          put api('/user', @user), { email: 'test@test.com' }
          @user.reload
        end.to change { @user.email }
      end
    end
    it "should update blog" do
      expect do
        put api('/user', @user), { blog: 'new-blog' }
        @user.reload
      end.to change { @user.blog }
    end
    it "should update uid" do
      expect do
        put api('/user', @user), { uid: 'new-uid' }
        @user.reload
      end.to change { @user.uid }
    end
  end

  describe "GET /user/authorized_organizations" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @organization_another = create :organization, namespace: namespace
      @actions_one = Action.options_array_for(:youxin)
      @actions_other = Action.options_array_for(:organization)

      @organization.authorize_cover_offspring(@admin, @actions_one)
      @organization_another.authorize_cover_offspring(@admin, @actions_other)
    end
    it "should return authorized_organizations" do
      get api('/user/authorized_organizations', @admin)
      response.status.should == 200
      json_response.should be_an Array
      json_response.map { |org| org['id'] }.should include(@organization.id.as_json)
      json_response.map { |org| org['id'] }.should include(@organization_another.id.as_json)
    end

    context "params[:actions]" do
      it "should return authorized actions organizations when single params[:actions]" do
        @organization.push_member(@admin)
        get api('/user/authorized_organizations', @admin), actions: [:create_youxin]
        response.status.should == 200
        json_response.should be_an Array
        json_response.should == [
          {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url,
            parent_id: nil,
            members: 1
          }
        ].as_json
      end
      it "should return authorized actions organizations when multi params[:actions]" do
        get api('/user/authorized_organizations', @admin), actions: [:create_youxin, :create_organization]
        response.status.should == 200
        json_response.should be_an Array
        json_response.should == [].as_json
      end
    end
  end

  describe "GET /user/receipt_organizations" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @organization_1 = create :organization, namespace: namespace
      @organization_2 = create :organization, parent: @organization_1, namespace: namespace
      @organization_3 = create :organization, parent: @organization_1, namespace: namespace
      @organization_4 = create :organization, parent: @organization_2, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of organizations which have sent a post to user (nested)" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      @receipt = @user.receipts.first
      get api('/user/receipt_organizations', @user)
      response.status.should == 200
      json_response.should be_an Array
      json_response.should == [
        {
          id: @organization_1.id,
          name: @organization_1.name,
          created_at: @organization_1.created_at,
          avatar: @organization_1.avatar.url,
          receipts: 1,
          unread_receipts: 1,
          last_receipt: {
            id: @receipt.id,
            read: @receipt.read,
            favorited: false,
            origin: @receipt.origin,
            post: {
              id: @receipt.post.id,
              title: @receipt.post.title,
              body: @receipt.post.body,
              body_html: @receipt.post.body_html,
              created_at: @receipt.post.created_at,
              attachments: [],
              forms: []
            }
          }
        }
      ].as_json
    end
    it "should return the array of organizations which have sent a post to user" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_3, @organization_4].map(&:id)
      get api('/user/receipt_organizations', @user)
      @receipt_1 = @user.receipts.from_organization(@organization_1).first
      @receipt_2 = @user.receipts.from_organization(@organization_3).first
      @receipt_3 = @user.receipts.from_organization(@organization_4).first
      response.status.should == 200
      json_response.should be_an Array
      json_response.should == [
        {
          id: @organization_1.id,
          name: @organization_1.name,
          created_at: @organization_1.created_at,
          avatar: @organization_1.avatar.url,
          receipts: 1,
          unread_receipts: 1,
          last_receipt: {
            id: @receipt_1.id,
            read: @receipt_1.read,
            favorited: false,
            origin: @receipt_1.origin,
            post: {
              id: @receipt_1.post.id,
              title: @receipt_1.post.title,
              body: @receipt_1.post.body,
              body_html: @receipt_1.post.body_html,
              created_at: @receipt_1.post.created_at,
              attachments: [],
              forms: []
            }
          }
        },
        {
          id: @organization_3.id,
          name: @organization_3.name,
          created_at: @organization_3.created_at,
          avatar: @organization_3.avatar.url,
          receipts: 1,
          unread_receipts: 1,
          last_receipt: {
            id: @receipt_2.id,
            read: @receipt_2.read,
            favorited: false,
            origin: @receipt_2.origin,
            post: {
              id: @receipt_2.post.id,
              title: @receipt_2.post.title,
              body: @receipt_2.post.body,
              body_html: @receipt_2.post.body_html,
              created_at: @receipt_2.post.created_at,
              attachments: [],
              forms: []
            }
          }
        },
        {
          id: @organization_4.id,
          name: @organization_4.name,
          created_at: @organization_4.created_at,
          avatar: @organization_4.avatar.url,
          receipts: 1,
          unread_receipts: 1,
          last_receipt: {
            id: @receipt_3.id,
            read: @receipt_3.read,
            favorited: false,
            origin: @receipt_3.origin,
            post: {
              id: @receipt_3.post.id,
              title: @receipt_3.post.title,
              body: @receipt_3.post.body,
              body_html: @receipt_3.post.body_html,
              created_at: @receipt_3.post.created_at,
              attachments: [],
              forms: []
            }
          }
        }
      ].as_json
    end
  end

  describe "GET /user/receipt_users" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @organization_1 = create :organization, namespace: namespace
      @organization_2 = create :organization, parent: @organization_1, namespace: namespace
      @organization_3 = create :organization, parent: @organization_1, namespace: namespace
      @organization_4 = create :organization, parent: @organization_2, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of users who have sent a post to user" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      @receipt = @user.receipts.first
      get api('/user/receipt_users', @user)
      response.status.should == 200
      json_response.should be_an Array
      json_response.should == [
        {
          id: @admin.id,
          email: @admin.email,
          name: @admin.name,
          created_at: @admin.created_at,
          avatar: @admin.avatar.url,
          phone: @admin.phone,
          receipts: 1,
          unread_receipts: 1,
          last_receipt: {
            id: @receipt.id,
            read: @receipt.read,
            favorited: false,
            origin: @receipt.origin,
            post: {
              id: @receipt.post.id,
              title: @receipt.post.title,
              body: @receipt.post.body,
              body_html: @receipt.post.body_html,
              created_at: @receipt.post.created_at,
              attachments: [],
              forms: [],
            }
          }
        }
      ].as_json
    end
  end

  describe "GET /user/receipts" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @organization_1 = create :organization, namespace: namespace
      @organization_2 = create :organization, parent: @organization_1, namespace: namespace
      @organization_3 = create :organization, parent: @organization_1, namespace: namespace
      @organization_4 = create :organization, parent: @organization_2, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of receipts" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      get api('/user/receipts', @user)
      @receipt = @user.receipts.first
      @organization = @receipt.organizations.first
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
  describe "GET /user/unread_receipts" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @organization_1 = create :organization, namespace: namespace
      @organization_2 = create :organization, parent: @organization_1, namespace: namespace
      @organization_3 = create :organization, parent: @organization_1, namespace: namespace
      @organization_4 = create :organization, parent: @organization_2, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of receipts" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      get api('/user/unread_receipts', @user)
      @receipt = @user.receipts.first
      @organization = @receipt.organizations.first
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
  describe "GET /user/favorite_receipts" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @organization_1 = create :organization, namespace: namespace
      @organization_2 = create :organization, parent: @organization_1, namespace: namespace
      @organization_3 = create :organization, parent: @organization_1, namespace: namespace
      @organization_4 = create :organization, parent: @organization_2, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of favorited receipts" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      @receipt = @user.receipts.first
      @receipt.favorites.create user_id: @user.id
      @organization = @receipt.organizations.first
      get api('/user/favorite_receipts', @user)
      response.status.should == 200
      json_response.should == [
        {
          id: @receipt.id,
          read: @receipt.read,
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
        }
      ].as_json
    end
  end

  describe "POST /user/ios_device_token" do
    before(:each) do
      @user = create :user, namespace: namespace
      @ios_device_token = 'a' * 64
    end
    it 'should return 204' do
      post api('/user/ios_device_token', @user), device_token: @ios_device_token
      response.status.should == 204
    end
    it "should create ios_device_token" do
      ios_device_token = 'a' * 64
      post api('/user/ios_device_token', @user), device_token: @ios_device_token
      @user.reload.ios_device_tokens.should include(@ios_device_token)
    end
    it 'should return errors' do
      post api('/user/ios_device_token', @user), device_token: 'invalid'
      json_response.should have_key('ios_device_tokens')
    end
  end
  describe "DELETE /user/ios_device_token" do
    before(:each) do
      @user = create :user, namespace: namespace
      @ios_device_token = 'a' * 64
      @user.add_ios_device_token @ios_device_token
    end
    it 'should return 204' do
      delete api('/user/ios_device_token', @user), device_token: @ios_device_token
      response.status.should == 204
    end
    it "should remove ios_device_token of user" do
      delete api('/user/ios_device_token', @user), device_token: @ios_device_token
      @user.reload.ios_device_tokens.should be_blank
    end
    it 'should return errors' do
      delete api('/user/ios_device_token', @user), device_token: 'invalid'
      json_response.should have_key('ios_device_tokens')
    end
  end

  describe "GET /user/notifications" do
    before(:each) do
      @user = create :user, namespace: namespace
    end
    it "should return the correct notification_channel and notification counters" do
      get api('/user/notifications', @user)
      json_response.should == {
        notification_channel: @user.notification_channel,
        notifications: {
          comment_notifications: 0,
          organization_notifications: 0,
          message_notifications: 0
        }
      }.as_json
    end
  end
  describe "GET /user/notifications_timeline" do
    before(:each) do
      @user = create :user, namespace: namespace
      @another_user = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @organization.push_members([@user, @another_user])
      @organization_notification = @user.notifications.first

      @post = create :post, author: @user, organization_ids: [@organization].map(&:id)
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @another_user.id })
      @comment_notification = @user.notifications.first

      @conversation = @another_user.send_message_to([@user], 'body')
      @message = @conversation.messages.first
      @message_notification = @user.notifications.first
    end
    it "should return the notifications" do
      get api('/user/notifications_timeline', @user)
      json_response.should == [
        {
          id: @message_notification.id,
          created_at: @message_notification.created_at,
          read: @message_notification.read,
          notificationable_type: @message_notification._type,
          notificationable: {
            id: @message.id,
            created_at: @message.created_at,
            body: @message.body,
            conversation: {
              id: @conversation.id,
              created_at: @conversation.created_at,
              updated_at: @conversation.updated_at
            },
            user: {
              id: @another_user.id,
              name: @another_user.name,
              avatar: @another_user.avatar.url,
              email: @another_user.email,
              created_at: @another_user.created_at,
              phone: @another_user.phone
            }
          }
        },
        {
          id: @comment_notification.id,
          created_at: @comment_notification.created_at,
          read: false,
          notificationable_type: @comment_notification._type,
          notificationable: {
            id: @comment.id,
            body: @comment.body,
            created_at: @comment.created_at,
            user: {
              id: @another_user.id,
              name: @another_user.name,
              avatar: @another_user.avatar.url,
              email: @another_user.email,
              created_at: @another_user.created_at,
              phone: @another_user.phone
            },
            commentable_type: @comment.commentable_type,
            commentable: {
              id: @post.id,
              title: @post.title,
              body: @post.body,
              body_html: @post.body_html,
              created_at: @post.created_at
            }
          }
        },
        {
          id: @organization_notification.id,
          created_at: @organization_notification.created_at,
          read: false,
          notificationable_type: @organization_notification._type,
          notificationable: {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          },
          status: @organization_notification.status
        }
      ].as_json
    end
  end
  describe "GET /user/notifications_timeline/unread" do
    before(:each) do
      @user = create :user, namespace: namespace
      @another_user = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @organization.push_members([@user, @another_user])
      @organization_notification = @user.notifications.first

      @post = create :post, author: @user, organization_ids: [@organization].map(&:id)
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @another_user.id })
      @comment_notification = @user.notifications.first

      @conversation = @another_user.send_message_to([@user], 'body')
      @message = @conversation.messages.first
      @message_notification = @user.notifications.first
    end
    it "should return the unread notifications" do
      get api('/user/notifications_timeline/unread', @user)
      json_response.should == [
        {
          id: @message_notification.id,
          created_at: @message_notification.created_at,
          read: @message_notification.read,
          notificationable_type: @message_notification._type,
          notificationable: {
            id: @message.id,
            created_at: @message.created_at,
            body: @message.body,
            conversation: {
              id: @conversation.id,
              created_at: @conversation.created_at,
              updated_at: @conversation.updated_at
            },
            user: {
              id: @another_user.id,
              name: @another_user.name,
              avatar: @another_user.avatar.url,
              email: @another_user.email,
              created_at: @another_user.created_at,
              phone: @another_user.phone
            }
          }
        },
        {
          id: @comment_notification.id,
          created_at: @comment_notification.created_at,
          read: false,
          notificationable_type: @comment_notification._type,
          notificationable: {
            id: @comment.id,
            body: @comment.body,
            created_at: @comment.created_at,
            user: {
              id: @another_user.id,
              name: @another_user.name,
              avatar: @another_user.avatar.url,
              email: @another_user.email,
              created_at: @another_user.created_at,
              phone: @another_user.phone
            },
            commentable_type: @comment.commentable_type,
            commentable: {
              id: @post.id,
              title: @post.title,
              body: @post.body,
              body_html: @post.body_html,
              created_at: @post.created_at
            }
          }
        },
        {
          id: @organization_notification.id,
          created_at: @organization_notification.created_at,
          read: false,
          notificationable_type: @organization_notification._type,
          notificationable: {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          },
          status: @organization_notification.status
        }
      ].as_json
    end
    it "should return the correct unread notifications when read" do
      @comment_notification.read!
      get api('/user/notifications_timeline/unread', @user)
      json_response.size.should == 2
    end
  end
  describe "GET /user/comment_notifications" do
    before(:each) do
      @user = create :user, namespace: namespace
      @admin = create :user, namespace: namespace
      organization = create :organization, namespace: namespace
      organization.push_member(@user)
      actions_youxin = Action.options_array_for(:youxin)
      organization.authorize_cover_offspring(@admin, actions_youxin)
      @post = create :post, author: @admin, organization_ids: [organization].map(&:id)
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
    end
    it "should return comment_notifications" do
      notification = @admin.notifications.first
      get api('/user/comment_notifications', @admin)
      json_response.should == [
        {
          id: notification.id,
          created_at: notification.created_at,
          read: false,
          notificationable_type: notification._type,
          notificationable: {
            id: @comment.id,
            body: @comment.body,
            created_at: @comment.created_at,
            user: {
              id: @user.id,
              email: @user.email,
              name: @user.name,
              created_at: @user.created_at,
              avatar: @user.avatar.url,
              phone: @user.phone
            },
            commentable_type: @comment.commentable_type,
            commentable: {
              id: @post.id,
              title: @post.title,
              body: @post.body,
              body_html: @post.body_html,
              created_at: @post.created_at
            }
          }
        }
      ].as_json
    end
  end
  describe "GET /user/organization_notifications" do
    before(:each) do
      @user = create :user, namespace: namespace
      admin = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @organization.add_member(@user)
      @add_notification = @user.notifications.first
      @organization.remove_member(@user)
      @remove_notification = @user.notifications.first
    end
    it "should return organization notifications" do
      get api('/user/organization_notifications', @user)
      json_response.should == [
        {
          id: @remove_notification.id,
          created_at: @remove_notification.created_at,
          read: false,
          notificationable_type: @remove_notification._type,
          notificationable: {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          },
          status: @remove_notification.status
        },
        {
          id: @add_notification.id,
          created_at: @add_notification.created_at,
          read: false,
          notificationable_type: @add_notification._type,
          notificationable: {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          },
          status: @add_notification.status
        }
      ].as_json
    end
  end
  describe "GET /user/message_notifications" do
    before(:each) do
      @user_one = create :user, namespace: namespace
      @user_another = create :user, namespace: namespace
      body = 'body'
      @conversation = @user_one.send_message_to([@user_another], body)
      @message = @conversation.messages.first
    end
    it "should return message notifications" do
      notification = @user_another.notifications.first
      get api('/user/message_notifications', @user_another)
      json_response.should == [
        {
          id: notification.id,
          created_at: notification.created_at,
          read: notification.read,
          notificationable_type: notification._type,
          notificationable: {
            id: @message.id,
            created_at: @message.created_at,
            body: @message.body,
            conversation: {
              id: @conversation.id,
              created_at: @conversation.created_at,
              updated_at: @conversation.updated_at
            },
            user: {
              id: @user_one.id,
              email: @user_one.email,
              name: @user_one.name,
              created_at: @user_one.created_at,
              avatar: @user_one.avatar.url,
              phone: @user_one.phone
            }
          }
        }
      ].as_json
    end
  end

  describe "GET /user/comment_notifications/unread" do
    before(:each) do
      @user = create :user, namespace: namespace
      @admin = create :user, namespace: namespace
      organization = create :organization, namespace: namespace
      organization.push_member(@user)
      actions_youxin = Action.options_array_for(:youxin)
      organization.authorize_cover_offspring(@admin, actions_youxin)
      @post = create :post, author: @admin, organization_ids: [organization].map(&:id)
      @comment_one = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @notification_one = @admin.notifications.first
      @comment_another = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @notification_another = @admin.notifications.first
    end
    it "should return unread comment_notifications" do
      @notification_one.read!
      get api('/user/comment_notifications/unread', @admin)
      json_response.should == [
        {
          id: @notification_another.id,
          created_at: @notification_another.created_at,
          read: false,
          notificationable_type: @notification_another._type,
          notificationable: {
            id: @comment_another.id,
            body: @comment_another.body,
            created_at: @comment_another.created_at,
            user: {
              id: @user.id,
              email: @user.email,
              name: @user.name,
              created_at: @user.created_at,
              avatar: @user.avatar.url,
              phone: @user.phone
            },
            commentable_type: @comment_another.commentable_type,
            commentable: {
              id: @post.id,
              title: @post.title,
              body: @post.body,
              body_html: @post.body_html,
              created_at: @post.created_at
            }
          }
        }
      ].as_json
    end
    it "should return blank array of unread comment_notifications" do
      @notification_one.read!
      @notification_another.read!
      get api('/user/comment_notifications/unread', @admin)
      json_response.should == [].as_json
    end
  end
  describe "GET /user/organization_notifications/unread" do
    before(:each) do
      @user = create :user, namespace: namespace
      admin = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @organization.add_member(@user)
      @add_notification = @user.notifications.first
      @organization.remove_member(@user)
      @remove_notification = @user.notifications.first
    end
    it "should return unread organization notifications" do
      @add_notification.read!
      get api('/user/organization_notifications/unread', @user)
      json_response.should == [
        {
          id: @remove_notification.id,
          created_at: @remove_notification.created_at,
          read: false,
          notificationable_type: @remove_notification._type,
          notificationable: {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url
          },
          status: @remove_notification.status
        }
      ].as_json
    end
    it "should return blank array of unread organization_notifications" do
      @add_notification.read!
      @remove_notification.read!
      get api('/user/organization_notifications/unread', @user)
      json_response.should == [].as_json
    end
  end
  describe "GET /user/message_notifications/unread" do
    before(:each) do
      @user_one = create :user, namespace: namespace
      @user_another = create :user, namespace: namespace
      body = 'body'
      @conversation = @user_one.send_message_to([@user_another], body)
      @message_one = @conversation.messages.first
      @notification_one = @user_another.notifications.first
      @user_one.send_message_to(@user_another, body)
      @message_another = @conversation.messages.first
      @notification_another = @user_another.notifications.first
    end
    it "should return message notifications" do
      @notification_one.read!
      get api('/user/message_notifications/unread', @user_another)
      json_response.should == [
        {
          id: @notification_another.id,
          created_at: @notification_another.created_at,
          read: @notification_another.read,
          notificationable_type: @notification_another._type,
          notificationable: {
            id: @message_another.id,
            created_at: @message_another.created_at,
            body: @message_another.body,
            conversation: {
              id: @conversation.id,
              created_at: @conversation.created_at,
              updated_at: @conversation.updated_at
            },
            user: {
              id: @user_one.id,
              name: @user_one.name,
              avatar: @user_one.avatar.url,
              email: @user_one.email,
              phone: @user_one.phone,
              created_at: @user_one.created_at
            }
          }
        }
      ].as_json
    end
    it "should return blank array of unread message_notifications" do
      @notification_one.read!
      @notification_another.read!
      get api('/user/message_notifications/unread', @user_another)
      json_response.should == [].as_json
    end
  end

  describe "GET /users/:id" do
    context "/" do
      before(:each) do
        @user = create :user, namespace: namespace
        @another_user = create :user, namespace: namespace
      end
      it "should return the info of a single user" do
        get api("/users/#{@user.id}", @user)
        response.status.should == 200
        json_response.should == {
          id: @user.id,
          email: @user.email,
          name: @user.name,
          phone: @user.phone,
          created_at: @user.created_at,
          avatar: @user.avatar.url,
          header: @user.header.url,
          bio: @user.bio,
          gender: @user.gender,
          qq: @user.qq,
          blog: @user.blog,
          uid: @user.uid
        }.as_json
      end
      it "should not return phone" do
        get api("/users/#{@another_user.id}", @user)
        response.status.should == 200
        json_response['phone'].should be_nil
      end
    end

    context "/organizations" do
      before(:each) do
        @user = create :user, namespace: namespace
        @organization = create :organization, namespace: namespace
        @organization.push_member(@user)
      end
      it "should return the array of organizations which the user is in" do
        get api("/users/#{@user.id}/organizations", @user)
        response.status.should == 200
        json_response.should == [
          {
            id: @organization.id,
            name: @organization.name,
            created_at: @organization.created_at,
            avatar: @organization.avatar.url,
            parent_id: @organization.parent_id,
            members: @organization.members.size
          }
        ].as_json
      end
    end

    context "/receipts" do
      before(:each) do
        @admin = create :user, namespace: namespace
        @user = create :user, namespace: namespace
        @organization = create :organization, namespace: namespace
        @actions_youxin = Action.options_array_for(:youxin)
        @actions_organization = Action.options_array_for(:organization)

        @organization.authorize_cover_offspring(@admin, @actions_youxin)
        @organization.push_member(@user)
      end
      it "should return the array of receipts which created by single user" do
        @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
        get api("/users/#{@admin.id}/receipts", @user)
        @receipt = @user.receipts.first
        @organization = @receipt.organizations.first
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
      before(:each) do
        @admin = create :user, namespace: namespace
        @user = create :user, namespace: namespace
        @organization = create :organization, namespace: namespace
        @actions_youxin = Action.options_array_for(:youxin)
        @actions_organization = Action.options_array_for(:organization)

        @organization.authorize_cover_offspring(@admin, @actions_youxin)
        @organization.push_member(@user)
      end
      it "should return the array of unread receipts from single user" do
        @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
        get api("/users/#{@admin.id}/unread_receipts", @user)
        @receipt = @user.receipts.unread.first
        @organization = @receipt.organizations.first
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
  end

  describe "GET /user/conversations" do
    before(:each) do
      @user = create :user, namespace: namespace
      @user_one = create :user, namespace: namespace
      @user_another = create :user, namespace: namespace
      @body = 'body'
    end
    it "should return conversations of current user" do
      conversation_one = @user.send_message_to([@user_one, @user_another], @body)
      conversation_two = @user.send_message_to(@user_one, @body)
      conversation_three = @user.send_message_to(@user_another, @body)
      get api('/user/conversations', @user)
      json_response.size.should == 3
    end
  end
end
