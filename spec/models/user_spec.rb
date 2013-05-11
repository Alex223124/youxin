require 'spec_helper'

describe User do
  let(:user) { build :user }
  subject { user }

  describe "Association" do
    it { should have_many(:user_organization_position_relationships) }
    it { should have_many(:user_actions_organization_relationships) }
  end

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:organization_ids) }
    it { should respond_to(:organizations) }
    it { should respond_to(:position_in_organization) }
    it { should respond_to(:human_position_in_organization) }
    it { should respond_to(:authorized_organizations) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :user).to be_valid
  end

  describe "#organizations" do
    before do
      @organization = create :organization
      @user = create :user
    end
    it "should return correctly" do
      @organization.push_member(@user)
      @user.organizations.include?(@organization).should be_true
    end
  end
  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#authorized_organizations" do
    it "should return the array of authorized organizations" do
      @organization = create :organization
      @user = create :user
      actions = Action.options_array_for(:organization)
      @organization.authorize(@user, actions)
      @user.authorized_organizations.should include(@organization)
    end
  end

  describe "#destroy" do
    before do
      @organization = create :organization
      @user = create :user
      @organization.push_member(@user)
    end
    it "should remove organizations" do
      @user.destroy
      @user.organizations.should be_blank
    end
    it "should remove user from organization" do
      @user.destroy
      @organization.reload.member_ids.include?(@user.id).should be_false
    end
  end

  describe "invalid attributes" do
    context "name" do
      context "is blank" do
        before { user.name = '' }
        its(:valid?) { should be_false }
      end
    end

    context "avatar" do
      it "return url of avatar" do
        avatar_path = Rails.root.join("spec/factories/images/avatar.png")
        user = create :user, avatar: Rack::Test::UploadedFile.new(avatar_path)
        user.avatar.file.should_not be_blank
        user.avatar.url.should_not be_blank
        user.avatar.url.should == "/uploads/avatar/#{user.id}.png"
      end
    end
  end

  describe "#update_with_password" do
    context "without password" do
      before do
        user.save
        user.update_with_password name: 'name-modify'
        user.reload
      end
      its(:name) { should == 'name-modify' }
    end

    context "with password" do
      before do
        user.save
        user.update_with_password name: 'name-modify', password: 'invalid_password'
        user.reload
      end
      its(:name) { should_not == 'name-modify' }
    end
  end
end
