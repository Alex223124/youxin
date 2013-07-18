require 'spec_helper'

describe Message do
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:conversation) }
  end

  describe "Respond to" do
    it { should respond_to(:body) }
  end

  describe "attributes" do
    before(:each) do
      @user = create :user
      @message = build :message
      @conversation = create :conversation, originator_id: @user.id
    end
    context "fails" do
      it "blank body" do
        @message.body = ''
        @message.save
        @message.should have(1).error_on(:body)
      end
      it "blank user" do
        @message.save
        @message.should have(1).error_on(:user)
      end
      it "blank conversation" do
        @message.save
        @message.should have(1).error_on(:conversation)
      end
    end
    it "should valid" do
      @message.user = @user
      @message.conversation = @conversation
      @message.should be_valid
    end
  end
end
