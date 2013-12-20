require 'spec_helper'

describe HomeController do
  describe "GET index" do
    it "should return http success" do
      pending
      namespace = create :namespace
      user = create :user, namespace: namespace
      login_user user
      get :index
      response.should be_success
    end
    it "should redirect to sign_in page" do
      get :index
      response.should redirect_to(introduction_path)
    end
  end
  describe "GET privacy" do
    it "should return http success" do
      get :privacy
      response.should be_success
    end
  end
  describe "GET terms" do
    it "should return http success" do
      get :terms
      response.should be_success
    end
  end
  describe "GET app" do
    it "should return http success" do
      get :app
      response.should be_success
    end
  end
  describe "GET welcome" do
    it "should return http success" do
      get :welcome
      response.should be_success
    end
  end
  describe "GET introduction" do
    it "should return http success" do
      get :introduction
      response.should be_success
    end
  end
end
