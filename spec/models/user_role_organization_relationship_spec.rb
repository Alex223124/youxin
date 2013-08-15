require 'spec_helper'

describe UserRoleOrganizationRelationship do
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
    it { should belong_to(:organization) }
  end
  describe ".create" do
    before(:each) do
      @organization = create :organization
      @child = create :organization, parent: @organization
      @user = create :user
      @actions = Action.options_array_for(:organization)
      @role = create :role, actions: @actions
    end
    it "should authorize to organizations" do
      expect do
        @user.user_role_organization_relationships.create role_id: @role.id,
                                                          organization_id: @organization.id
      end.to change { @organization.user_actions_organization_relationships.count }.by(1)
    end
    it "should authorize to child" do
      expect do
        @user.user_role_organization_relationships.create role_id: @role.id,
                                                          organization_id: @organization.id
      end.to change { @child.user_actions_organization_relationships.count }.by(1)
    end
    it "should add actions to organizations" do
      @user.user_role_organization_relationships.create role_id: @role.id,
                                                        organization_id: @organization.id
      @organization.user_actions_organization_relationships.first.actions.should == @actions
    end
  end
end
