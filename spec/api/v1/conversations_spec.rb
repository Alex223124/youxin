require 'spec_helper'

describe Youxin::API, 'conversations' do
  include ApiHelpers

  describe "GET /conversations/:" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
      body = 'body'
      @conversation = @user.send_message_to([@user_one, @user_another], body)
      @message = @conversation.messages.first
    end
    it "should return the conversations" do
      get api("/conversations/#{@conversation.id}", @user)
      response.status.should == 200
      json_response.should == {
        id: @conversation.id,
        created_at: @conversation.created_at,
        updated_at: @conversation.updated_at,
        last_message: {
          id: @message.id,
          created_at: @message.created_at,
          body: @message.body,
          conversation_id: @message.conversation_id,
          user: {
            id: @message.user.id,
            email: @message.user.email,
            name: @message.user.name,
            created_at: @message.user.created_at,
            avatar: @message.user.avatar.url
          }
        },
        originator: {
          id: @conversation.originator.id,
          email: @conversation.originator.email,
          name: @conversation.originator.name,
          created_at: @conversation.originator.created_at,
          avatar: @conversation.originator.avatar.url
        },
        participants: [
          {
            id: @user_one.id,
            email: @user_one.email,
            name: @user_one.name,
            created_at: @user_one.created_at,
            avatar: @user_one.avatar.url
          },
          {
            id: @user_another.id,
            email: @user_another.email,
            name: @user_another.name,
            created_at: @user_another.created_at,
            avatar: @user_another.avatar.url
          },
          {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            created_at: @user.created_at,
            avatar: @user.avatar.url
          }
        ]
      }.as_json
    end
    it "should return 200 when participants resquest" do
      get api("/conversations/#{@conversation.id}", @user)
      response.status.should == 200
    end
    it "should return 401" do
      get api("/conversations/#{@conversation.id}")
      response.status.should == 401
    end
    it "should return 403" do
      user_three = create :user
      get api("/conversations/#{@conversation.id}", user_three)
      response.status.should == 403
    end
    it "should return 404" do
      get api("/conversations/not_exist", @user)
      response.status.should == 404
    end
  end
  describe "GET /conversations/:id/messages" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
      body = 'body'
      @conversation = @user.send_message_to([@user_one, @user_another], body)
      @message = @conversation.messages.first
    end
    it "should return messages of the conversation" do
      get api("/conversations/#{@conversation.id}/messages", @user)
      json_response.should == [
        {
          id: @message.id,
          created_at: @message.created_at,
          body: @message.body,
          conversation_id: @message.conversation_id,
          user: {
            id: @message.user.id,
            email: @message.user.email,
            name: @message.user.name,
            created_at: @message.user.created_at,
            avatar: @message.user.avatar.url
          }
        }
      ].as_json
    end
    it "should return 403" do
      user_three = create :user
      get api("/conversations/#{@conversation.id}/messages", user_three)
      response.status.should == 403
    end
  end
  describe "POST /conversation/:id/messages" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
      @body = 'body'
      @conversation = @user.send_message_to([@user_one, @user_another], @body)
      @message = @conversation.messages.first
    end
    it "should create message" do
      post api("/conversations/#{@conversation.id}/messages", @user), body: @body
      new_message = Message.first
      json_response.should == {
        id: new_message.id,
        conversation_id: new_message.conversation_id,
        created_at: new_message.created_at,
        body: new_message.body,
        user: {
          id: new_message.user.id,
          name: new_message.user.name,
          email: new_message.user.email,
          created_at: new_message.user.created_at,
          avatar: new_message.user.avatar.url
        }
      }.as_json
    end
    it "should not create message without body" do
      post api("/conversations/#{@conversation.id}/messages", @user), body: ''
      response.status.should == 400
    end
    it "should return 403" do
      user_three = create :user
      post api("/conversations/#{@conversation.id}/messages", user_three), body: @body
      response.status.should == 403
    end
  end
  describe "POST /conversations" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
    end
    it "should create a conversation" do
      post api("/conversations", @user), participant_ids: [@user_one, @user_another].map(&:id)
      json_response['participants'].size.should == 3
      json_response['originator']['id'].should == @user.id.as_json
    end
    it "should return 400" do
      post api("/conversations", @user), participant_ids: [@user].map(&:id)
      response.status.should == 400
    end
    it "should return 404" do
      post api("/conversations", @user), participant_ids: ['not_exist']
      response.status.should == 404
    end
  end
end