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
    it { should respond_to(:subdomain) }
    it { should respond_to(:subdomain_enabled) }
  end

  describe 'Attributes' do
    context '#subdomain' do
      it 'should be valid if subdomain blank' do
        namespace.subdomain = ''
        namespace.should be_valid
      end
      it 'should be invalid if subdomain blank when subdomain_enabled is true' do
        namespace.subdomain_enabled = true
        namespace.subdomain = ''
        namespace.should_not be_valid
      end
      it 'should be invalid when starting with number' do
        namespace.subdomain = '9abc'
        namespace.should_not be_valid
      end
      it 'should be invalid when starting with -' do
        namespace.subdomain = '-abc'
        namespace.should_not be_valid
      end
      it 'should be invalid when endding with -' do
        namespace.subdomain = 'abc-'
        namespace.should_not be_valid
      end
      it 'should be invalid when subdomain is not uniqueness' do
        namespace.subdomain = 'abc'
        namespace.save
        namespace_another = build :namespace, subdomain: 'abc'
        namespace_another.should_not be_valid
      end
      it 'should be valid when endding with number' do
        namespace.subdomain = 'abc9'
        namespace.should be_valid
      end
      it 'should be valid when starting with letter' do
        namespace.subdomain = 'abc9'
        namespace.should be_valid
      end
      it 'should be valid when contains more than one -' do
        namespace.subdomain = 'ab--c-9'
        namespace.should be_valid
      end
    end
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
