require 'spec_helper'

describe Conversation do
  describe "Association" do
    it { should have_and_belong_to_many(:participants) }
    it { should have_many(:messages) }
  end

  describe "Respond to" do
    it { should respond_to(:originator) }
    it { should respond_to(:last_message) }
  end

  describe "attributes" do
    before(:each) do
      @user = create :user
      @conversation = build :conversation
    end
    context "fails" do
      it "blank originator_id" do
        @conversation.should have(1).error_on(:originator_id)
      end
    end
    it "should be valid" do
      @conversation.originator_id = @user.id
      @conversation.should be_valid
    end
  end

  describe "#remove_user" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
      body = 'body'
      @user.send_message_to([@user_one, @user_another], body)
      @conversation = Conversation.first
    end
    it "should remove user from conversation" do
      @conversation.remove_user(@user_one)
      @user_one.conversations.count.should == 0
      @conversation.participants.should_not include(@user_one)
    end
    it "should remove user from conversation when given user_id" do
      @conversation.remove_user(@user_one.id)
      @user_one.reload
      @user_one.conversations.count.should == 0
      @conversation.participants.should_not include(@user_one)
    end
  end

  describe "#add_user" do
    before(:each) do
      @user = create :user
      @user_one = create :user
      @user_another = create :user
      @user_three = create :user
      body = 'body'
      @user.send_message_to([@user_one, @user_another], body)
      @conversation = Conversation.first
    end
    it "should add user to conversation" do
      expect do
        @conversation.add_user(@user_three)
      end.to change { @user_three.conversations.count }.by(1)
      @conversation.participants.should include(@user_three)
    end
    it "should add user to conversation when given user_id" do
      expect do
        @conversation.add_user(@user_three.id)
        @user_three.reload
      end.to change { @user_three.conversations.count }.by(1)
      @conversation.participants.should include(@user_three)
    end
  end
end
