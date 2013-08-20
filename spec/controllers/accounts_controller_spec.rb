require 'spec_helper'

describe AccountsController do
  include JsonParser

  let(:current_user) { create :user }

  describe "GET organizations" do
    before(:each) do
      organization_one = create :organization
      organization_another = create :organization
      organization_one.add_member current_user
      organization_another.add_member current_user
      login_user current_user
    end
    it "should return the array of organizations" do
      get :organizations
      json_response.should have_key('organizations')
      json_response['organizations'].should be_a_kind_of(Array)
    end
    it "should return organizations which current user is in" do
      get :organizations
      json_response['organizations'].size.should == 2
    end
    it "should return 401" do
      sign_out current_user
      get :organizations, format: :json
      response.status.should == 401
    end
  end
  describe "GET authorized_organizations" do
    before(:each) do
      login_user current_user
      organization_one = create :organization
      organization_two = create :organization
      organization_three = create :organization
      @action_one = Action.options_array[0]
      @action_two = Action.options_array[1]
      @action_three = Action.options_array[2]
      organization_one.authorize(current_user, [@action_one, @action_two])
      organization_two.authorize(current_user, [@action_two, @action_three])
      organization_three.authorize(current_user, [@action_three])
    end
    it "should return the array of authorized_organizations" do
      get :authorized_organizations
      json_response.should have_key('authorized_organizations')
      json_response['authorized_organizations'].should be_a_kind_of(Array)
    end
    it "should return the authorized_organizations" do
      get :authorized_organizations
      json_response['authorized_organizations'].size.should == 3
    end
    it "should return the authorized_organizations with action params" do
      get :authorized_organizations, actions: [@action_two]
      json_response['authorized_organizations'].size.should == 2
    end
    it "should return the authorized_organizations with more action params" do
      get :authorized_organizations, actions: [@action_two, @action_three]
      json_response['authorized_organizations'].size.should == 1
    end
  end
  describe "GET recent_authorized_organizations" do
    before(:each) do
      login_user current_user
      organization_one = create :organization
      organization_two = create :organization
      organization_three = create :organization
      @action_one = Action.options_array[0]
      @action_two = Action.options_array[1]
      @action_three = Action.options_array[2]
      organization_one.authorize(current_user, [@action_one, @action_two])
      organization_two.authorize(current_user, [@action_two, @action_three])
      organization_three.authorize(current_user, [@action_three])
    end
    it "should return the recent_authorized_organizations" do
      get :recent_authorized_organizations
      json_response.should have_key('recent_authorized_organizations')
    end
    it "should return the array of recent_authorized_organizations" do
      get :recent_authorized_organizations
      json_response['recent_authorized_organizations']['organization_ids'].should be_a_kind_of(Array)
      json_response['recent_authorized_organizations']['organization_clan_ids'].should be_a_kind_of(Array)
    end
  end
  describe "PUT update" do
    before(:each) do
      login_user current_user
      @valid_attrs = {
        name: 'new-name'
      }
    end
    it "should update current user" do
      expect do
        put :update, user: @valid_attrs
        current_user.reload
      end.to change { current_user.name }
    end
    it "should return updated user" do
      put :update, user: @valid_attrs
      json_response.should have_key('user')
    end
    it "should return 422" do
      @valid_attrs.merge!({ name: '' })
      put :update, user: @valid_attrs
      response.status.should == 422
    end
  end
  describe "GET show" do
    before(:each) do
      login_user current_user
    end
    it "should return current user " do
      get :show
      json_response.should have_key('user')
    end
    it "should return attributes of current user" do
      get :show
      json_response['user']['name'].should == current_user.name
    end
  end
  describe "GET created_receipts" do
    before(:each) do
      login_user current_user
    end
    it "should return receipts created by current user" do
      get :created_receipts
      json_response.should have_key('created_receipts')
    end
  end
  describe "GET favorited_receipts" do
    before(:each) do
      login_user current_user
    end
    it "should return receipts created by current user" do
      get :favorited_receipts
      json_response.should have_key('favorited_receipts')
    end
  end
end