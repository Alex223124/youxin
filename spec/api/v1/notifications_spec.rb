require 'spec_helper'

describe Youxin::API, 'notifications' do
  include ApiHelpers

  before(:each) do
    @user = create :user
    @notification = create :notification_base, user_id: @user.id
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
  end
end
