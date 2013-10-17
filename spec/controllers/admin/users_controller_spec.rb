require 'spec_helper'

describe Admin::UsersController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, phone: Youxin.config.admin_phones.first, namespace: namespace }

  before(:each) do
    login_user current_user
  end

  describe "GET show" do
    it "should return http success" do
      get :show, namespace_id: namespace.id, id: current_user.id
      response.should be_success
      assigns(:user).should == current_user
    end
  end

end
