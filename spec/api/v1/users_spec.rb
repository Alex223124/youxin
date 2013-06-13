require 'spec_helper'

describe Youxin::API, 'users' do
  include ApiHelpers

  describe "GET /user" do
    before(:each) do
      @user = create :user
    end
    it "should return current user" do
      get api('/user', @user)
      response.status.should == 200
      json_response['email'].should == @user.email
      json_response['name'].should == @user.name
    end
    it "should return 403" do
      get api('/user')
      response.status.should == 401
    end
  end

  describe "GET /user/authorized_organizations" do
    before(:each) do
      @admin = create :user
      @organization = create :organization
      @organization_another = create :organization
      @actions_one = Action.options_array_for(:youxin)
      @actions_other = Action.options_array_for(:organization)

      @organization.authorize_cover_offspring(@admin, @actions_one)
      @organization_another.authorize_cover_offspring(@admin, @actions_other)
    end
    it "should return authorized_organizations" do
      get api('/user/authorized_organizations', @admin)
      response.status.should == 200
      json_response.should be_an Array
      json_response.to_json.should == [
        {
          id: @organization.id,
          name: @organization.name,
          parent_id: @organization.parent_id,
          avatar: @organization.avatar.url
        },
        {
          id: @organization_another.id,
          name: @organization_another.name,
          parent_id: @organization_another.parent_id,
          avatar: @organization_another.avatar.url
        }
      ].to_json
    end

    context "params[:actions]" do
      it "should return authorized actions organizations when single params[:actions]" do
        get api('/user/authorized_organizations', @admin), actions: [:create_youxin]
        response.status.should == 200
        json_response.should be_an Array
        json_response.to_json.should == [
          {
            id: @organization.id,
            name: @organization.name,
            parent_id: @organization.parent_id,
            avatar: @organization.avatar.url
          }
        ].to_json
      end
      it "should return authorized actions organizations when multi params[:actions]" do
        get api('/user/authorized_organizations', @admin), actions: [:create_youxin, :create_organization]
        response.status.should == 200
        json_response.should be_an Array
        json_response.to_json.should == [].to_json
      end
    end
  end
end