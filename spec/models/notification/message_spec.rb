require 'spec_helper'

describe Notification::Message do
  describe "Association" do
    it { should belong_to(:message) }
  end
  describe "Respond to" do
    # it { should respond_to(:) }
  end

  describe "create" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
      @body = 'body'
    end
    it "should not create notification to sender" do
      expect do
        @user.send_message_to(@user_one, @body)
      end.to change { @user.message_notifications.count }.by(0)
    end
    context "direct message" do
      it "should create a notification to recipient" do
        expect do
          @user.send_message_to(@user_one, @body)
        end.to change { @user_one.message_notifications.count }.by(1)
      end
    end
    context "group chat" do
      it "should create notifications to recipients" do
        @user.send_message_to([@user_one, @user_another], @body)
        @user_one.message_notifications.count.should == 1
        @user_another.message_notifications.count.should == 1
      end
    end
    context "conversation" do
      it "should create a notification to recipient when direct message" do
        @user.send_message_to(@user_one, @body)
        conversation = Conversation.first
        expect do
          @user.send_message_to(conversation, @body)
        end.to change { @user_one.message_notifications.count }.by(1)
      end
      it "should create notifications to recipients when group chat" do
        @user.send_message_to([@user_one, @user_another], @body)
        conversation = Conversation.first
        @user.send_message_to(conversation, @body)
        @user_one.message_notifications.count.should == 2
        @user_another.message_notifications.count.should == 2
      end
    end
  end
end
