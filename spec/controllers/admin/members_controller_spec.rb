require 'spec_helper'

describe Admin::MembersController do
  before(:each) do
    @organization = create :organization
    @user = create :user
    @another_user = create :user
    request.env["HTTP_REFERER"] = admin_organizations_url
  end
  describe "GET 'index'" do
    it "returns http success" do
      get 'index', id: @organization.id
      response.should be_success
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
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
      expect {
        put :update, {
          id: @organization.id,
          member_ids: [@user.id, @another_user.id]
        }
      }.to change{ @organization.reload.members.count }.by(2)
    end
  end


end
