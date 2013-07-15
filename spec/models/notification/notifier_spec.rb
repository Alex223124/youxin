require 'spec_helper'
require 'timeout'

describe Notification::Notifier do
  before(:each) do
    @user = create :user, ios_device_token: 'ios_device_token_string'
    @faye_data = { avatar: 'avatar.png', title: 'title', body: 'body' }
    @ios_data = { alert: 'alert', badge: 12 }
  end
  describe ".publish_to_ios_device" do
    before do
      @server = Grocer.server(port: 2195)
      @server.accept # starts listening in background
    end

    after do
      @server.close
    end

    it "should send notification to ios_device" do
      Notification::Notifier.publish_to_ios_device([@user], @ios_data)
      Timeout.timeout(3) {
        notification = @server.notifications.pop
        expect(notification.alert).to eq('alert')
        expect(notification.badge).to eq(12)
      }
    end
  end
  describe ".publish_to_faye_client" do
    it "should send notification to faye_client" do
      Notification::Notifier.publish_to_faye_client([@user], @faye_data)
    end
  end

end
