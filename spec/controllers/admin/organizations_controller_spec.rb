require 'spec_helper'

describe Admin::OrganizationsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "POST 'create'" do
    it "should create an instance" do
      expect {
        post :create, organization: attributes_for(:organization)
      }.to change(Organization, :count).by(1)
    end
  end

  describe "DELETE 'destroy'" do
    it "should delete an instance" do
      organization = create :organization
      expect {
        delete :destroy, id: organization.id
      }.to change(Organization, :count).by(-1)
    end

    it "returns not delete an instance" do
      expect { 
        delete :destroy, id: :not_exist
      }.to change(Organization, :count).by(0)
    end
  end
end
