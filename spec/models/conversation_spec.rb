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
end
