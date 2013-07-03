require 'spec_helper'

describe Notification::Organization do
  let(:organization_notification) { build :notification_organization }
  subject { organization_notification }
  describe "Association" do
    it { should belong_to(:organization) }
  end
  describe "Validations" do
    it { should validate_inclusion_of(:status).to_allow('in', 'out') }
    it { should validate_presence_of(:organization) }
  end

  before do
    @organization = create :organization
    @user = create :user
    @position = create :position
  end
  describe "push_member" do
    it "should create organization_notification to user" do
      expect do
        @organization.push_member(@user, @position)
      end.to change { @user.organization_notifications.count }.by(1)
    end
    it "should not create organization_notification to user" do
      @organization.push_member(@user, @position)
      expect do
        @organization.push_member(@user, @position)
      end.to change { @user.organization_notifications.count }.by(0)
    end
  end
  describe "pull_member" do
    before(:each) do
      @organization.push_member(@user)
    end
    it "should create organization_notification to user" do
      expect do
        @organization.pull_member(@user)
      end.to change { @user.organization_notifications.count }.by(1)
    end
    it "should not create organization_notification to user" do
      @organization.pull_member(@user)
      expect do
        @organization.pull_member(@user)
      end.to change { @user.organization_notifications.count }.by(0)
    end
  end
end
