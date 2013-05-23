require 'spec_helper'

describe Youxin::API, 'session' do
  include ApiHelpers

  let(:user) { create :user }

  describe "POST /session" do
    context "when valid password" do
      it "should return private token" do
        post api('/session'), email: user.email, password: '12345678'
        response.status.should == 201

        json_response['email'].should == user.email
        json_response['private_token'].should == user.private_token
        json_response['name'].should == user.name
      end
    end

    context "when invalid password" do
      it "should return authentication error" do
        post api('/session'), email: user.email, password: '123456'
        response.status.should == 401

        json_response['email'].should be_nil
        json_response['private_token'].should be_nil
        json_response['name'].should be_nil
      end
    end

    context "when empty password" do
      it "should return authentication error" do
        post api('/session'), email: user.email
        response.status.should == 401

        json_response['email'].should be_nil
        json_response['private_token'].should be_nil
        json_response['name'].should be_nil
      end
    end

    context "when empty email" do
      it "should return authentication error" do
        post api('/session'), password: user.password
        response.status.should == 401

        json_response['email'].should be_nil
        json_response['private_token'].should be_nil      
        json_response['name'].should be_nil
      end
    end

  end
end
