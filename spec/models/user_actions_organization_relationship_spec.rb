require 'spec_helper'

describe UserActionsOrganizationRelationship do
  let(:user_actions_organization_relationship) { build :user_actions_organization_relationship }
  subject { user_actions_organization_relationship }
  describe "Respond to" do
    it { should respond_to(:user_id) }
    it { should respond_to(:organization_id) }
    it { should respond_to(:actions) }
  end

  describe "validation" do
    context "fails" do
      it "actions not a array" do
        user_actions_organization_relationship.actions = 'not_a_array'
        user_actions_organization_relationship.valid?
        user_actions_organization_relationship.should have(1).error_on(:actions)
      end
      it "actions not in Action.options" do
        user_actions_organization_relationship.actions = ['not_in']
        user_actions_organization_relationship.valid?
        user_actions_organization_relationship.should have(1).error_on(:actions)
      end
    end

    context "successed" do
      it "single actions in Action.options" do
        user_actions_organization_relationship.actions = [Action.options.collect { |k, v| k }.first]
        user_actions_organization_relationship.should be_valid
      end
      it "multi actions in Action.options" do
        user_actions_organization_relationship.actions = Action.options.collect { |k, v| k }
        user_actions_organization_relationship.should be_valid
      end
    end
  end

  describe "#actions" do
    it "should return a array" do
      user_actions_organization_relationship.actions.should be_a_kind_of Array
    end
  end
end
