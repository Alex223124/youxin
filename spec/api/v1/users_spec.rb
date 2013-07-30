require 'spec_helper'

describe Youxin::API, 'users' do
  include ApiHelpers

  describe "GET /user" do
    before(:each) do
      @user = create :user
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

  describe "GET /user/authorized_organizations" do
    before(:each) do
      @admin = create :user
      @organization = create :organization
      @organization_another = create :organization
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
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
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
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
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
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
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
              avatar: @receipt.author.avatar.url
            }
          }
        }
      ].as_json
    end
  end
  describe "GET /user/unread_receipts" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
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
              avatar: @receipt.author.avatar.url
            }
          }
        }
      ].as_json
    end
  end
  describe "GET /user/favorite_receipts" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
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
              avatar: @receipt.author.avatar.url
            }
          }
        }
      ].as_json
    end
  end

  describe "POST /user/ios_device_token" do
    before(:each) do
      @user = create :user
    end
    it "should create ios_device_token" do
      ios_device_token = 'ios_device_token_string'
      post api('/user/ios_device_token', @user), device_token: ios_device_token
      @user.reload.ios_device_token.should == ios_device_token
    end
  end
  describe "DELETE /user/ios_device_token" do
    before(:each) do
      @user = create :user
    end
    it "should remove ios_device_token of user" do
      ios_device_token = 'ios_device_token_string'
      post api('/user/ios_device_token', @user), device_token: ios_device_token
      delete api('/user/ios_device_token', @user)
      @user.reload.ios_device_token.should be_blank
    end
  end

  describe "GET /user/notifications" do
    before(:each) do
      @user = create :user
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
  describe "GET /user/comment_notifications" do
    before(:each) do
      @user = create :user
      @admin = create :user
      organization = create :organization
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
              avatar: @user.avatar.url
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
      @user = create :user
      admin = create :user
      @organization = create :organization
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
      @user_one = create :user
      @user_another = create :user
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
              avatar: @user_one.avatar.url
            }
          }
        }
      ].as_json
    end
  end

  describe "GET /user/comment_notifications/unread" do
    before(:each) do
      @user = create :user
      @admin = create :user
      organization = create :organization
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
              avatar: @user.avatar.url
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
      @user = create :user
      admin = create :user
      @organization = create :organization
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
      @user_one = create :user
      @user_another = create :user
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
              email: @user_one.email,
              name: @user_one.name,
              created_at: @user_one.created_at,
              avatar: @user_one.avatar.url
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
        @user = create :user
      end
      it "should return the info of a single user" do
        get api("/users/#{@user.id}", @user)
        response.status.should == 200
        json_response.should == {
          id: @user.id,
          email: @user.email,
          name: @user.name,
          created_at: @user.created_at,
          avatar: @user.avatar.url
        }.as_json
      end
    end

    context "/organizations" do
      before(:each) do
        @user = create :user
        @organization = create :organization
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
            avatar: @organization.avatar.url
          }
        ].as_json
      end
    end

    context "/receipts" do
      before(:each) do
        @admin = create :user
        @user = create :user
        @organization = create :organization
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
                avatar: @receipt.author.avatar.url
              }
            }
          }
        ].as_json
      end
    end

    context "/unread_receipts" do
      before(:each) do
        @admin = create :user
        @user = create :user
        @organization = create :organization
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
                avatar: @receipt.author.avatar.url
              }
            }
          }
        ].as_json
      end
    end
  end

  describe "GET /user/conversations" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
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