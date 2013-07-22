require 'spec_helper'

describe Organization do
  let(:organization) { build :organization }
  subject { organization }

  describe "Association" do
    it { should have_many(:user_organization_position_relationships) }
    it { should have_many(:user_actions_organization_relationships) }
    it { should have_many(:applications) }
    it { should have_many(:organization_notifications) }
    it { should have_many(:user_role_organization_relationships) }
  end

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:parent) }
    it { should respond_to(:children) }
    it { should respond_to(:offspring) }
    it { should respond_to(:members) }
    it { should respond_to(:push_member) }
    it { should respond_to(:pull_member) }
    it { should respond_to(:push_members) }
    it { should respond_to(:pull_members) }
    it { should respond_to(:add_member) }
    it { should respond_to(:remove_member) }
    it { should respond_to(:add_members) }
    it { should respond_to(:remove_members) }
    it { should respond_to(:authorize) }
    it { should respond_to(:authorize_cover_offspring) }
    it { should respond_to(:authorized_users) }
    it { should respond_to(:deauthorize) }
    it { should respond_to(:deauthorize_cover_offspring) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :organization).to be_valid
  end

  describe "#parent" do
    it "should return nil if parent_id is nil" do
      organization.save
      organization.parent.should be_nil
    end
    it "should return parent if parent_id is not nil" do
      organization.save
      parent = organization
      child = create(:organization, parent_id: parent.id)
      child.parent.should == parent
    end
  end

  describe "#children" do
    it "should return children" do
      organization.save
      parent = organization
      organization1 = create :organization, parent: parent 
      organization2 = create :organization, parent: parent 
      (parent.child_ids - [organization1.id, organization2.id]).should be_blank
    end
  end

  describe "#offspring" do
    it "should return offspring" do
      parent = create :organization
      current = create :organization, parent: parent
      child = create :organization, parent: current
      feature = create :organization, parent: child
      [current, child, feature].all? { |organization| parent.offspring.include?(organization) }.should be_true
    end
  end

  describe "members" do
    before do
      @organization = create :organization
      @user = create :user
      @another_user = create :user
      @position = create :position
    end
    context "#push_member" do
      it "should add members to organization" do
        @organization.push_member(@user)
        @organization.members.should include(@user)
      end
      it "should not add member to organization if it exists in organization" do
        @organization.push_member(@user)
        @organization.members.count.should == 1
        @organization.push_member(@user)
        @organization.members.count.should == 1
      end
      it "should add with providing id" do
        @organization.push_member(@user.id)
        @organization.members.should include(@user)
      end
      it "should do nothing if member does not exists" do
        @organization.push_member('not_exist')
        @organization.members.count.should == 0
      end
    end

    context "#push_member with position" do
      it "should add members to organization with position" do
        @organization.push_member(@user, @position)
        @user.position_in_organization(@organization).should == @position
      end
      it "should add members to organization with position_id" do
        @organization.push_member(@user, @position.id)
        @user.position_in_organization(@organization).should == @position
      end
    end

    context "#pull_member" do
      it "should remove members from organization" do
        @organization.push_member(@user)
        @organization.pull_member(@user)
        @organization.members.should_not include(@user)
      end

      it "should do nothing if it is not the member of organization" do
        @organization.push_member(@user)
        @organization.pull_member(@another_user)
        @organization.members.count.should == 1
      end

      it "should remove with providing id" do
        @organization.push_member(@user)
        @organization.pull_member(@user.id)
        @organization.members.should_not include(@user)
      end
    end

    context "#push_members" do
      it "should add members" do
        @organization.push_members([@user, @another_user])
        @organization.members.should include(@user)
        @organization.members.should include(@another_user)
      end

      it "should add members with providing ids" do
        @organization.push_members([@user.id, @another_user.id])
        @organization.members.should include(@user)
        @organization.members.should include(@another_user)
      end
    end
    context "#push_members with position" do
      it "should add members with position" do
        @organization.push_members([@user, @another_user], @position)
        @user.position_in_organization(@organization).should == @position
        @another_user.position_in_organization(@organization).should == @position
      end
      it "should add members with position_id" do
        @organization.push_members([@user, @another_user], @position.id)
        @user.position_in_organization(@organization).should == @position
        @another_user.position_in_organization(@organization).should == @position
      end
    end

    context "#pull_members" do
      before do
        @organization.push_members([@user, @another_user])
      end
      it "should remove members" do
        @organization.pull_members([@user, @another_user])
        @organization.members.should_not include(@user)
        @organization.members.should_not include(@another_user)
      end

      it "should remove members with providing ids" do
        @organization.pull_members([@user.id, @another_user.id])
        @organization.members.should_not include(@user)
        @organization.members.should_not include(@another_user)
      end
    end
  end

  describe "#authorize" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @actions = Action.options_array_for(:organization)
    end
    it "should authorize actions to user" do
      @organization.authorize(@user, @actions)
      authorization = @organization.user_actions_organization_relationships.where(user_id: @user.id).first
      authorization.actions.should == @actions
    end
    it "should authorize actions to user with user_id" do
      @organization.authorize(@user.id, @actions)
      authorization = @organization.user_actions_organization_relationships.where(user_id: @user.id).first
      authorization.actions.should == @actions
    end

    it "should not authorize actions to user cover the offspring" do
      parent = @organization
      current = create :organization, parent: parent
      child = create :organization, parent: current
      feature = create :organization, parent: child
      parent.authorize(@user, @actions)
      [current, child, feature].any? { |organization| organization.authorized_users.include?(@user) }.should be_false
      [current, child, feature].any? { |organization| @user.authorized_organizations.include?(organization) }.should be_false
    end

    it "should deauthorize uesr if actions are blank" do
      @organization.authorize(@user, @actions)
      @organization.authorize(@user, [])
      @organization.authorized_users.should_not include(@user)
    end

    it "should do nothing if user not exist" do
      @organization.authorize('not_exist', @actions)
      @organization.authorized_users.should be_blank
    end
  end
  describe "#authorize_cover_offspring" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @actions = Action.options_array_for(:organization)
    end
    it "should authorize actions to user cover the offspring" do
      parent = @organization
      current = create :organization, parent: parent
      child = create :organization, parent: current
      feature = create :organization, parent: child

      parent.authorize_cover_offspring(@user, @actions)
      [parent, current, child, feature].all? { |organization| organization.reload.authorized_users.include?(@user) }.should be_true
      [parent, current, child, feature].all? { |organization| @user.authorized_organizations.include?(organization) }.should be_true
    end
    it "should authorize actions to user for new organization" do
      @organization.authorize(@user, @actions)
      @child = create :organization, parent: @organization
      @child.authorized_users.should include(@user)
      authorization = @organization.user_actions_organization_relationships.where(user_id: @user.id).first
      authorization.actions.should == @actions
    end
  end
  describe "#deauthorize" do
    before(:each) do
      @user = create :user

      @parent = create :organization
      @current = create :organization, parent: @parent
      @child = create :organization, parent: @current
      @feature = create :organization, parent: @child

      @actions = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(@user, @actions)
    end
    it "should deauthorize user" do
      @current.deauthorize(@user)
      @current.authorized_users.should_not include(@user)
    end
    it "should deauthorize user with user_id" do
      @current.deauthorize(@user.id)
      @current.authorized_users.should_not include(@user)
    end

    it "should not deauthorize user from offspring and parent" do
      @current.deauthorize(@user)
      @child.reload.authorized_users.should include(@user)
      @parent.reload.authorized_users.should include(@user)
    end
    it "should do nothing if user not exist" do
      expect{
        @current.deauthorize('not_exist')
        }.to change(@current.authorized_users, :count).by(0)
    end
  end
  describe "#deauthorize_cover_offspring" do
    it "should deauthorize user from offspring" do
      @user = create :user

      @parent = create :organization
      @current = create :organization, parent: @parent
      @child = create :organization, parent: @current
      @feature = create :organization, parent: @child

      @actions = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(@user, @actions)

      @current.deauthorize_cover_offspring(@user)
      @child.reload.authorized_users.should_not include(@user)
      @feature.reload.authorized_users.should_not include(@user)
      @parent.reload.authorized_users.should include(@user)
    end
  end
  describe "#authorized_users" do
    it "should return the array of authorized users" do
      organization.save
      user = create :user
      actions = Action.options_array_for(:organization)
      organization.authorize(user, actions)
      organization.authorized_users.should include(user)
    end
  end

  describe "#user_organization_position_relationships" do
    before do
      @organization = create :organization
      @user = create :user
      @another_user = create :user
    end

    context "add" do
      it "should create a user_organization_position_relationship if not exists" do
        @organization.push_member(@user)
        @organization.user_organization_position_relationships.where(user_id: @user.id).count.should == 1
      end
      it "should do nothing if the user_organization_position_relationship exists" do
        @organization.push_member(@user)
        @organization.push_member(@user)
        @organization.user_organization_position_relationships.where(user_id: @user.id).count.should == 1
      end      
    end

    context "remove" do
      before(:each) do
        @organization.push_member(@user)
      end
      it "should remove the user_organization_position_relationship" do
        @organization.pull_member(@user)
        @organization.user_organization_position_relationships.where(user_id: @user.id).count.should == 0
      end
      it "should do nothing if the user_organization_position_relationship does not exist" do
        @organization.pull_member(@user)
        @organization.pull_member(@user)
        @organization.user_organization_position_relationships.where(user_id: @user.id).count.should == 0
      end
    end
  end

  describe "#destroy" do
    before do
      @organization = create :organization
      @user = create :user
      @organization.push_member(@user)
    end

    it "should remove users" do
      @organization.destroy
      @organization.members.count.should == 0
    end

    it "should remove organization from user" do
      @organization.destroy
      @user.reload.organization_ids.should_not include(@organization.id)
    end
  end

  describe "#create" do
    it "should raise error" do
      organization = build :organization, parent_id: 1
      organization.valid?
      organization.should have(1).error_on(:parent_id)
    end
  end

  describe "attributes" do
    context "name" do
      describe "is blank" do
        before { organization.name = '' }
        its(:valid?) { should be_false }
      end
    end

    context "parent_id" do
      context "fails" do
        describe "parent_id not exist" do
          before { organization.parent_id = 123 }
          its(:valid?) { should be_false }
        end
      end

      context "successed" do
        describe "is blank" do
          before { organization.parent_id = '' }
          its(:valid?) { should be_true }
        end
        describe "is nil" do
          before { organization.parent_id = nil }
          its(:valid?) { should be_true }
        end
      end
    end

    context "avatar" do
      it "return url of avatar" do
        avatar_path = Rails.root.join("spec/factories/images/avatar.png")
        organization = create :organization, avatar: Rack::Test::UploadedFile.new(avatar_path)
        organization.avatar.file.should_not be_blank
        organization.avatar.url.should_not be_blank
        organization.avatar.url.should == "/uploads/avatar/organization/#{organization.id}.png"
      end
    end

  end
end
