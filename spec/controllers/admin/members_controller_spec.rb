require 'spec_helper'

describe Admin::MembersController do
  before(:each) do
    @organization = create :organization
    @user = create :user
    @another_user = create :user
    @request.env["HTTP_REFERER"] = admin_organizations_url
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = create :user
    login_user(@current_user)
  end
  describe "GET 'index'" do
    it "returns http success" do
      get 'index', id: @organization.id
      response.should be_success
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      @organization.authorize(@current_user, [:remove_member])
      @organization.push_members([@user.id, @another_user.id])
      expect {
        delete 'destroy', {
          id: @organization.id,
          member_ids: [@user.id, @another_user.id]
        }
      }.to change{ @organization.reload.members.count }.by(-2)
    end
  end

  describe "PUT 'update'" do
    it "should add members to organization" do
      @organization.authorize(@current_user, [:add_member])
      expect {
        put :update, {
          id: @organization.id,
          member_ids: [@user.id, @another_user.id]
        }
      }.to change{ @organization.reload.members.count }.by(2)
    end
  end


end
