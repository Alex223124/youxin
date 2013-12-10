require 'spec_helper'

describe Admin::OrganizationsController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, phone: Youxin.config.admin_phones.first, namespace: namespace }
  let(:organization) { create :organization }

  before(:each) do
    login_user current_user
  end

  describe "GET show" do
    it "should return http success" do
      get :show, id: organization.id
      response.should be_success
      assigns(:organization).should == organization
    end
  end

end
