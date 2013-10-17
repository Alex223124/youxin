require 'spec_helper'

describe Admin::NamespacesController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, phone: Youxin.config.admin_phones.first, namespace: namespace }
  before(:each) do
    login_user current_user
  end

  describe "GET index" do
    it "should return http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    it "should return http success" do
      get :show, id: namespace.id
      response.should be_success
      assigns(:namespace).should == namespace
    end
  end

end
