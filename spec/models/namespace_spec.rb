require 'spec_helper'

describe Namespace do

  let(:namespace) { create :namespace }

  describe "Association" do
    it { should have_many(:organizations) }
    it { should have_many(:users) }
    it { should have_many(:positions) }
    it { should have_many(:roles) }
  end

  describe "organizations" do
    before(:each) do
      @organization = create :organization, namespace: namespace
    end
    it { @organization.namespace.should == namespace }
    it { namespace.organizations.should == [@organization] }
  end

  describe "users" do
    before(:each) do
      @user = create :user, namespace: namespace
    end
    it { @user.namespace.should == namespace }
    it { namespace.users.should == [@user] }
  end

  describe "positions" do
    before(:each) do
      @position = create :position, namespace: namespace
    end
    it { @position.namespace.should == namespace }
    it { namespace.positions.should == [@position] }
  end

  describe "roles" do
    before(:each) do
      @role = create :role, namespace: namespace
    end
    it { @role.namespace.should == namespace }
    it { namespace.roles.should == [@role] }
  end

end
