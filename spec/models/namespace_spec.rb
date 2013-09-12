require 'spec_helper'

describe Namespace do

  let(:namespace) { create :namespace }

  describe "Association" do
    it { should have_many(:organizations) }
    it { should have_many(:users) }
    it { should have_many(:positions) }
    it { should have_many(:roles) }
  end

  describe 'Respond to' do
    it { should respond_to(:name) }
    it { should respond_to(:logo) }
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

  describe "logo" do
    it "return url of logo" do
      logo_path = Rails.root.join("spec/factories/images/logo.png")
      namespace = create :namespace, logo: Rack::Test::UploadedFile.new(logo_path)
      namespace.logo.file.should_not be_blank
      namespace.logo.url.should_not be_blank
    end
  end
end
