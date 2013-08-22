require 'spec_helper'

describe Role do
  describe "Association" do
    it { should have_many(:user_role_organization_relationships) }
    it { should belong_to(:namespace) }
  end
  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:actions) }
  end

  describe "Attributes" do
    it "should not be valid without namespace_id" do
      role = build :role
      role.namespace_id = nil
      role.should_not be_valid
    end
  end

end
