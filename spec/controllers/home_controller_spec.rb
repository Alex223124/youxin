require 'spec_helper'

describe HomeController do
  describe "GET index" do
    it "should return http success" do
      login_user
      get :index
      response.should be_success
    end
    it "should redirect to sign_in page" do
      get :index
      response.should redirect_to(new_user_session_path)
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
end
