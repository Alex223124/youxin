require 'spec_helper'

describe Youxin::API, 'notifications' do
  include ApiHelpers

  before(:each) do
    @user = create :user
    @notification = create :notification_base, user_id: @user.id
    @notification_one = create :notification_base, user_id: @user.id
  end
  describe "PUT /notifications/:id/read" do
    it "should mark the notification as read" do
      expect do
        put api("/notifications/#{@notification.id}/read", @user)
        @notification.reload
      end.to change { @notification.read }
    end
    it "should return 204" do
      put api("/notifications/#{@notification.id}/read", @user)
      response.status.should == 204
    end
    it "should return 404" do
      put api('/notifications/not_exists/read', @user)
      response.status.should == 404
    end
    it "should return 404" do
      user_another = create :user
      put api('/notifications/not_exists/read', user_another)
      response.status.should == 404
    end
  end

  describe 'GET /notifications/:id' do
    it 'should retrun 404' do
      get api('/notifications/not_exitst', @user)
      response.status.should == 404
    end
    it 'should return the notification' do
      get api("/notifications/#{@notification.id}", @user)
      json_response['id'].should == @notification.id.to_s
    end
  end

  describe "PUT /notifications/read" do
    it "should mark the notifications as read" do
      put api('/notifications/read', @user), notification_ids: [@notification, @notification_one].map(&:id)
      response.status.should == 204
      @notification.reload.read.should == true
      @notification_one.reload.read.should == true
    end
  end
end
