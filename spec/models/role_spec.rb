require 'spec_helper'

describe Role do
  describe "Association" do
    it { should have_many(:user_role_organization_relationships) }
  end
  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:actions) }
  end
end
