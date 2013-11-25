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
      json_response.should == {
        terms: Youxin.config.help.terms,
        privacy: Youxin.config.help.privacy,
        about_us: Youxin.config.help.about_us,
        ios_tips_and_tricks: Youxin.config.help.ios_tips_and_tricks,
        contact_email: Youxin.config.help.contact_email,
        faq: Youxin.config.help.faq
      }.as_json
    end
  end
  describe 'GET /help/last_android_version' do
    it 'should return the last android version and url' do
      get api('/help/last_android_version')
      response.status.should == 200
      json_response.should == {
        version: Youxin.config.help.android.version,
        version_code: Youxin.config.help.android.version_code,
        url: Youxin.config.help.android.url
      }.as_json
    end
  end
end
