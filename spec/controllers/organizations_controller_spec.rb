require 'spec_helper'

describe OrganizationsController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, namespace: namespace }
  before(:each) do
    login_user current_user
    @parent = create :organization, namespace: namespace
    @current = create :organization, parent: @parent, namespace: namespace
  end
  describe "GET index" do
    it "returns http success" do
      get :index
      response.should be_success
    end
    it "should return an array of organizations" do
      get :index
      json_response['organizations'].should be_a_kind_of Array
    end
    it "should return all organizations" do
      get :index
      json_response['organizations'].count.should == 2
    end
  end
  describe "POST create_children" do
    before(:each) do
      @another_organization = create :organization, namespace: namespace
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(current_user, actions_organization)
      member = create :user, namespace: namespace
      @parent.push_member(member)
      @valid_attrs = {
        name: 'new-name'
      }
    end
    it "should return 201" do
      post :create_children, id: @parent.id, organization: @valid_attrs
      response.status.should == 201
    end
    it "should create a new organization" do
      expect do
        post :create_children, id: @parent.id, organization: @valid_attrs
      end.to change { @parent.children.count }.by(1)
    end
    it "should return 422" do
      @valid_attrs.delete(:name)
      post :create_children, id: @parent.id, organization: @valid_attrs
      response.status.should == 422
    end
    it "should return 403" do
      post :create_children, id: @another_organization.id, organization: @valid_attrs
      response.status.should == 403
    end
  end
  describe "PUT update" do
    before(:each) do
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(current_user, actions_organization)
    end
    it "should return the updated organization" do
      put :update, id: @parent.id, organization: { name: 'new-name', bio: 'new-bio' }
      json_response.should have_key('organization')
    end
    it "should update name" do
      expect do
        put :update, id: @parent.id, organization: { name: 'new-name' }
        @parent.reload
      end.to change { @parent.name }
    end
    it "should update bio" do
      expect do
        put :update, id: @parent.id, organization: { bio: 'new-bio' }
        @parent.reload
      end.to change { @parent.bio }
    end
    it "should return 422" do
      put :update, id: @parent.id, organization: { name: '' }
      response.status.should == 422
    end
    it "should return 403" do
      another_organization = create :organization, namespace: namespace
      put :update, id: another_organization.id, organization: { name: 'new-name', bio: 'new-bio' }
      response.status.should == 403
    end
  end
  describe "DELETE destroy" do
    before(:each) do
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(current_user, actions_organization)
    end
    it "should return 204" do
      delete :destroy, id: @parent.id
      response.status.should == 204
    end
    it "should delete the organization" do
      expect do
        delete :destroy, id: @current.id
      end.to change { Organization.count }.by(-1)
    end
    it "should delete the organization and offspring" do
      expect do
        delete :destroy, id: @parent.id
      end.to change { Organization.count }.by(-2)
    end
    it "should return 403" do
      another_organization = create :organization, namespace: namespace
      delete :destroy, id: another_organization.id
      response.status.should == 403
    end
  end
  describe "GET authorized_users" do
    before(:each) do
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(current_user, actions_organization)
    end
    it "should return 200" do
      get :authorized_users, id: @parent.id
      response.should be_success
    end
    it "should return authorized_users" do
      get :authorized_users, id: @parent.id
      json_response['authorized_users'].count.should == 1
    end
  end
  describe "GET receipts" do
    it "should return receipts from the organization" do
      get :receipts, id: @parent.id
      json_response.should have_key('receipts')
    end
  end
end