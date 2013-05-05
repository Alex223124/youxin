require 'spec_helper'

describe Organization do
  let(:organization) { build :organization }
  subject { organization }

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:parent) }
    it { should respond_to(:children) }
    it { should respond_to(:members) }
    it { should respond_to(:push_member) }
    it { should respond_to(:pull_member) }
    it { should respond_to(:push_members) }
    it { should respond_to(:pull_members) }
    it { should respond_to(:add_member) }
    it { should respond_to(:remove_member) }
    it { should respond_to(:add_members) }
    it { should respond_to(:remove_members) }
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
      parent.child_ids.should == [organization1.id, organization2.id]
    end
  end

  describe "members" do
    before do
      @organization = create :organization
      @user = create :user
      @another_user = create :user
    end
    context "#push_member" do
      it "should add members to organization" do
        @organization.push_member(@user)
        @organization.members.include?(@user).should be_true
      end
      it "should not add member to organization if it exists in organization" do
        @organization.push_member(@user)
        @organization.members.count.should == 1
        @organization.push_member(@user)
        @organization.members.count.should == 1
      end
      it "should add with providing id" do
        @organization.push_member(@user.id)
        @organization.members.include?(@user).should be_true
      end
      it "should do nothing if member does not exists" do
        @organization.push_member('not_exist')
        @organization.members.count.should == 0
      end
    end

    context "#pull_member" do
      it "should remove members from organization" do
        @organization.push_member(@user)
        @organization.pull_member(@user)
        @organization.members.include?(@user).should be_false
      end

      it "should do nothing if it is not the member of organization" do
        @organization.push_member(@user)
        @organization.pull_member(@another_user)
        @organization.members.count.should == 1
      end

      it "should remove with providing id" do
        @organization.push_member(@user)
        @organization.pull_member(@user.id)
        @organization.members.include?(@user).should be_false
      end
    end

    context "#push_members" do
      it "should add members" do
        @organization.push_members([@user, @another_user])
        @organization.members.include?(@user).should be_true
        @organization.members.include?(@another_user).should be_true
      end

      it "should add members with providing ids" do
        @organization.push_members([@user.id, @another_user.id])
        @organization.members.include?(@user).should be_true
        @organization.members.include?(@another_user).should be_true
      end
    end

    context "#pull_members" do
      before do
        @organization.push_members([@user, @another_user])
      end
      it "should remove members" do
        @organization.pull_members([@user, @another_user])
        @organization.members.include?(@user).should be_false
        @organization.members.include?(@another_user).should be_false
      end

      it "should remove members with providing ids" do
        @organization.pull_members([@user.id, @another_user.id])
        @organization.members.include?(@user).should be_false
        @organization.members.include?(@another_user).should be_false
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
      @user.reload.organization_ids.include?(@organization.id).should be_false
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
  end
end
