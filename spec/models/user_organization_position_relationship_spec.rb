require 'spec_helper'

describe UserOrganizationPositionRelationship do
  let(:relationship) { build :user_organization_position_relationship }
  subject { relationship }

  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
    it { should belong_to(:position) }
  end

  describe "attributes" do
    context "failure" do
      before(:all) do
        @organization = create :organization
        @user = create :user
        @position = create :position
      end
      it "without user_id" do
        relationship = UserOrganizationPositionRelationship.new(
          organization_id: @organization.id,
          position_id: @position.id
        )
        relationship.valid?
        relationship.should have(1).error_on(:user_id)
      end
      it "without organization_id" do
        relationship = UserOrganizationPositionRelationship.new(
          user_id: @user.id,
          position_id: @position.id
        )
        relationship.valid?
        relationship.should have(1).error_on(:organization_id)
      end
    end
  end
end
