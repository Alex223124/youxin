require 'spec_helper'

describe Mobile::SessionsController do
  describe "GET new" do
    it "should return http success" do
      get :new
      response.should be_success
    end
  end
  describe 'POST create' do
    before(:each) do
      @password = '123456789'
      @namespace = create :namespace
      @user = create :user, password: @password, password_confirmation: @password
      @user_params = {
        login: @user.phone,
        password: @password
      }
    end
    it 'should redirect to mobile_root path' do
      post :create, user: @user_params
      response.should redirect_to(mobile_root_path)

    end
    it 'should not sign in user' do
      @user_params.merge!({
        password: 'not_matched'
      })
      post :create, user: @user_params
      response.should render_template('new')
    end
  end
end
