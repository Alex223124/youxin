require 'spec_helper'

describe Youxin::API, 'help' do
  include ApiHelpers
  describe "GET /help/avatar_versions" do
    it "should return the array of avatar_versions" do
      get api('/help/avatar_versions')
      response.status.should == 200
      json_response.should == Version.avatars.as_json
    end
  end
  describe "GET /help/header_versions" do
    it "should return the array of header_versions" do
      get api('/help/header_versions')
      response.status.should == 200
      json_response.should == Version.headers.as_json
    end
  end
  describe "GET /help/about" do
    it "should return the about" do
      get api('/help/about')
      response.status.should == 200
      json_response.should == Youxin.config.help.as_json
    end
  end
end