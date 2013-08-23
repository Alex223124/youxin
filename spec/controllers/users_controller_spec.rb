require 'spec_helper'

describe UsersController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, namespace: namespace }
  let(:user) { create :user, namespace: namespace }

  describe "GET organizations" do
    before(:each) do
      organization_one = create :organization, namespace: namespace
      organization_another = create :organization, namespace: namespace
      organization_one.add_member user
      organization_another.add_member user
      login_user current_user
    end
    it "should return the array of organizations" do
      get :organizations, id: user.id
      json_response.should have_key('organizations')
      json_response['organizations'].should be_a_kind_of(Array)
    end
    it "should return organizations which current user is in" do
      get :organizations, id: user.id
      json_response['organizations'].size.should == 2
    end
    it "should return 401" do
      sign_out current_user
      get :organizations, id: user.id, format: :json
      response.status.should == 401
    end
  end
  describe "GET authorized_organizations" do
    before(:each) do
      login_user current_user
      organization_one = create :organization, namespace: namespace
      organization_two = create :organization, namespace: namespace
      organization_three = create :organization, namespace: namespace
      @action_one = Action.options_array[0]
      @action_two = Action.options_array[1]
      @action_three = Action.options_array[2]
      organization_one.authorize(user, [@action_one, @action_two])
      organization_two.authorize(user, [@action_two, @action_three])
      organization_three.authorize(user, [@action_three])
    end
    it "should return the array of authorized_organizations" do
      get :authorized_organizations, id: user.id
      json_response.should have_key('authorized_organizations')
      json_response['authorized_organizations'].should be_a_kind_of(Array)
    end
    it "should return the authorized_organizations" do
      get :authorized_organizations, id: user.id
      json_response['authorized_organizations'].size.should == 3
    end
    it "should return the authorized_organizations with action params" do
      get :authorized_organizations, id: user.id, actions: [@action_two]
      json_response['authorized_organizations'].size.should == 2
    end
    it "should return the authorized_organizations with more action params" do
      get :authorized_organizations, id: user.id, actions: [@action_two, @action_three]
      json_response['authorized_organizations'].size.should == 1
    end
  end
  describe "PUT update" do
    before(:each) do
      login_user current_user
      organization = create :organization, namespace: namespace
      actions = [:edit_member]
      organization.authorize(current_user, actions)
      organization.add_member(user)
      @valid_attrs = {
        name: 'new-name'
      }
    end
    it "should update the user" do
      expect do
        put :update, id: user.id, user: @valid_attrs
        user.reload
      end.to change { user.name }
    end
    it "should update the user when current user is the user" do
      login_user user
      expect do
        put :update, id: user.id, user: @valid_attrs
        user.reload
      end.to change { user.name }
    end
    it "should return 204" do
      put :update, id: user.id, user: @valid_attrs
      response.status.should == 204
    end
    it "should return 422" do
      @valid_attrs.merge!({ name: '' })
      put :update, id: user.id, user: @valid_attrs
      response.status.should == 422
    end
    it "should return 403" do
      another_user = create :user, namespace: namespace
      login_user another_user
      put :update, id: user.id, user: @valid_attrs
      response.status.should == 403
    end
  end
  describe "GET show" do
    before(:each) do
      login_user current_user
    end
    it "should return current user " do
      get :show, id: user.id
      json_response.should have_key('user')
    end
    it "should return attributes of current user" do
      get :show, id: user.id
      json_response['user']['name'].should == user.name
    end
  end
  describe "GET receipts" do
    before(:each) do
      login_user current_user
    end
    it "should return receipts created by current user" do
      get :receipts, id: user.id
      json_response.should have_key('receipts')
    end
  end
end