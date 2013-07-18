require 'spec_helper'

describe Notification::Base do
  let(:notification_base) { build :notification_base }
  subject { notification_base }
  describe "Association" do
    it { should belong_to(:user) }
  end
  describe "Respons to" do
    it { should respond_to(:read) }
  end
  describe "Validations" do
    it { should validate_presence_of(:user_id) }
  end

  describe ".unread" do
    before(:each) do
      @user = create :user
      5.times do
        create :notification_base, user_id: @user.id
      end
    end
    it "should return the unread notifications" do
      @user.notifications.unread.count.should == 5
    end
  end

  describe "#read!" do
    before(:each) do
      @user = create :user
      5.times do
        create :notification_base, user_id: @user.id
      end
    end
    it "should return the unread notifications" do
      expect do
        @user.notifications.unread.sample.read!
      end.to change { @user.notifications.unread.count }.by(-1)
    end
  end
end
