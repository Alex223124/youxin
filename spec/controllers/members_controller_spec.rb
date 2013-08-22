# encoding: utf-8

require 'spec_helper'

describe MembersController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, namespace: namespace }
  let(:admin) { create :user, namespace: namespace }
  before(:each) do
    @parent = create :organization, namespace: namespace
    @current = create :organization, parent: @parent, namespace: namespace
    @parent.add_member(current_user)
    actions_user = Action.options_array_for(:user)
    @parent.authorize_cover_offspring(admin, actions_user)
  end
  describe "GET index" do
    before(:each) do
      login_user current_user
      3.times do
        @parent.add_member(create :user, namespace: namespace)
      end
    end
    it "should return http success" do
      get :index, organization_id: @parent.id
      response.should be_success
    end
    it "should return members of the organization" do
      get :index, organization_id: @parent.id
      json_response['members'].size.should == 4
    end
  end
  describe "POST create" do
    before(:each) do
      login_user admin
      @member_attrs = attributes_for :user
    end
    it "should add a member to organization" do
      expect do
        post :create, organization_id: @parent.id, member: @member_attrs
        @parent.reload
      end.to change { @parent.members.count }.by(1)
    end
    it "should return 422" do
      @member_attrs.delete(:name)
      post :create, organization_id: @parent.id, member: @member_attrs
      response.status.should == 422
    end
    it "should return 403" do
      another_organization = create :organization, namespace: namespace
      post :create, organization_id: another_organization.id, member: @member_attrs
      response.status.should == 403
    end
  end
  describe "POST import" do
    before(:each) do
      login_user admin
      xls_path = Rails.root.join('spec/factories/data/list.xls')
      @xls_file =Rack::Test::UploadedFile.new(xls_path, 'application/vnd.ms-excel')
    end
    it "should add members to the organization" do
      expect do
        post :import, organization_id: @parent.id, file: @xls_file
        @parent.reload
      end.to change { @parent.members.count }.by(3)
    end
    it "should return the unimport_users" do
      @parent.add_member create :user, name: '张三', email: 'zhangsan@y.x', phone: '18600000000', namespace: namespace
      post :import, organization_id: @parent.id, file: @xls_file
      json_response['members'].size.should == 2
      json_response['meta']['unimported_members'].size.should == 1
    end
    it "should return 400" do
      post :import, organization_id: @parent.id
      response.status.should == 400
    end
    it "should return 403" do
      another_organization = create :organization, namespace: namespace
      post :import, organization_id: another_organization.id
      response.status.should == 403
    end
  end
  describe "PUT update" do
    before(:each) do
      login_user admin
      @member_one = create :user, namespace: namespace
    end
    it "should add members to the organization" do
      expect do
        put :update, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
        @parent.reload
      end.to change { @parent.members.count }.by(1)
    end
    it "should add member with position to the organization" do
      position = create :position, namespace: namespace
      put :update, organization_id: @parent.id, member_ids: [@member_one].map(&:id), position_id: position.id
      @member_one.position_in_organization(@parent).should == position
    end
    it "should update position if user is in the organization" do
      position = create :position, namespace: namespace
      @parent.add_member(@member_one)
      put :update, organization_id: @parent.id, member_ids: [@member_one].map(&:id), position_id: position.id
      @member_one.position_in_organization(@parent).should == position
    end
    it "should return 400" do
      put :update, organization_id: @parent.id, member_ids: @member_one.id
      response.status.should == 400
    end
    it "should return 404" do
      put :update, organization_id: @parent.id, member_ids: ['not_exists']
      response.status.should == 404
    end
    it "should return 403" do
      login_user current_user
      put :update, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
      response.status.should == 403
    end
  end
  describe "DELETE destroy" do
    before(:each) do
      login_user admin
      @member_one = create :user, namespace: namespace
      @parent.add_member(@member_one)
    end
    it "should remove members from the organization" do
      expect do
        delete :destroy, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
        @parent.reload
      end.to change { @parent.members.count }.by(-1)
    end
    it "should return 204" do
      delete :destroy, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
      response.status.should == 204
    end
    it "should return 400" do
      delete :destroy, organization_id: @parent.id, member_ids: @member_one.id
      response.status.should == 400
    end
    it "should return 404" do
      delete :destroy, organization_id: @parent.id, member_ids: ['not_exists']
      response.status.should == 404
    end
    it "should return 403" do
      login_user current_user
      delete :destroy, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
      response.status.should == 403
    end
  end
  describe "PUT update_role" do
    before(:each) do
      login_user admin
      @member_one = create :user, namespace: namespace
      @role = create :role, actions: Action.options_array, namespace: namespace
    end
    it "should update role of user in the organization" do
      expect do
        put :update_role, organization_id: @parent.id, member_ids: [current_user].map(&:id), role_id: @role.id
      end.to change { current_user.user_role_organization_relationships.count }.by(1)
    end
    it "should update the role that user in the organization" do
      put :update_role, organization_id: @parent.id, member_ids: [current_user].map(&:id), role_id: @role.id
      current_user.role_in_organization(@parent).should == @role
    end
    it "should return 204" do
      put :update_role, organization_id: @parent.id, member_ids: [current_user].map(&:id), role_id: @role.id
      response.status.should == 204
    end
    it "should return 400" do
      put :update_role, organization_id: @parent.id, member_ids: @member_one.id, role_id: @role.id
      response.status.should == 400
    end
    it "should return 404" do
      put :update_role, organization_id: @parent.id, member_ids: ['not_exists'], role_id: @role.id
      response.status.should == 404
    end
    it "should return 404 about role" do
      put :update_role, organization_id: @parent.id, member_ids: [@member_one].map(&:id), role_id: 'not_exists'
      response.status.should == 404
    end
    it "should return 403" do
      login_user current_user
      put :update_role, organization_id: @parent.id, member_ids: [@member_one].map(&:id), role_id: @role.id
      response.status.should == 403
    end
  end
  describe "DELETE destroy_role" do
    before(:each) do
      login_user admin
      @member_one = create :user, namespace: namespace
      @role = create :role, actions: Action.options_array, namespace: namespace
      @member_one.user_role_organization_relationships.create(organization_id: @parent.id, role_id: @role.id)
    end
    it "should remove role of members in the organization" do
      delete :destroy_role, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
      @member_one.role_in_organization(@parent).should be_nil
    end
    it "should return 204" do
      delete :destroy_role, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
      response.status.should == 204
    end
    it "should return 400" do
      delete :destroy_role, organization_id: @parent.id, member_ids: @member_one.id
      response.status.should == 400
    end
    it "should return 404" do
      delete :destroy_role, organization_id: @parent.id, member_ids: ['not_exists']
      response.status.should == 404
    end
    it "should return 403" do
      login_user current_user
      delete :destroy_role, organization_id: @parent.id, member_ids: [@member_one].map(&:id)
      response.status.should == 403
    end
  end
end
