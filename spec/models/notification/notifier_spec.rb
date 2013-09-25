require 'spec_helper'
require 'timeout'

describe Notification::Notifier do
  before(:each) do
    ios_device_token_string = 'a' * 64
    @user = create :user, phone: '18600000000'
    @user.push_ios_device_token ios_device_token_string
    @faye_data = { avatar: 'avatar.png', title: 'title', body: 'body' }
    @ios_data = { alert: 'alert', badge: 12 }

    @author = create :user
    organization = create :organization
    organization.add_member(@user)
    post = create :post, author: @author, organization_ids: [organization].map(&:id)
    @receipt = create :receipt, post: post, user: @user
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
  describe ".publish_to_ios_device_async" do
    before do
      ResqueSpec.reset!
    end
    it "should do notifier.publish_to_ios_device to youxin_notification_queue" do
      Notification::Notifier.publish_to_ios_device_async([@user], @ios_data)
      PublishToIosDeviceJob.should have_queued([@user], @ios_data).in(:youxin_notification_queue)
    end
  end
  describe ".publish_to_faye_client" do
    it "should send notification to faye_client" do
      # Notification::Notifier.publish_to_faye_client([@user], @faye_data)
    end
  end
  describe ".publish_to_faye_client_async" do
    before do
      ResqueSpec.reset!
    end
    it "should do notifier.publish_to_faye_client to youxin_notification_queue" do
      Notification::Notifier.publish_to_faye_client_async([@user], @faye_data)
      PublishToFayeClientJob.should have_queued([@user], @faye_data).in(:youxin_notification_queue)
    end
  end
  describe ".publish_to_phone" do
    before(:each) do
      stub_request(:any, 'http://api.smsbao.com/sms').to_return(body: '0')
    end

    it "should send notification to user" do
      expect {
        Notification::Notifier.publish_to_phone(@receipt)
      }.to change(@author.sms_communication_records, :count).by(1)
    end
    it "should update status" do
      Notification::Notifier.publish_to_phone(@receipt)
      @author.sms_communication_records.last.status.should == '0'
    end
  end
  describe ".publish_to_phone_async" do
    before do
      ResqueSpec.reset!
    end
    it "should do notifier.publish_to_phone to youxin_notification_queue" do
      Notification::Notifier.publish_to_phone_async(@receipt)
      PublishToPhoneJob.should have_queued(@receipt).in(:youxin_notification_queue)
    end
  end

  describe ".make_landing_call_to_phone" do
    describe "succeeds" do
      before(:each) do
        raw_response_file = File.new(Rails.root.join("spec/factories/data/landing_call.xml"))
        stub_request(:any, /.*localhost:8883.*/)
          .to_return(status: 200, body: raw_response_file, headers: { 'Content-Type' => 'application/xml;charset=utf-8' })
      end
      it "should add a new call record" do
        expect do
          Notification::Notifier.make_landing_call_to_phone(@receipt)
        end.to change { @author.call_communication_records.count }.by(1)
      end

      it "should add call_sid and status_code" do
        Notification::Notifier.make_landing_call_to_phone(@receipt)
        record = @author.call_communication_records.first
        record.status.should == '000000'
        record.call_sid.should == 'a346467ca321c71dbd5e12f627123456'
      end
    end
    describe "fails" do
      before(:each) do
        raw_response_file = File.new(Rails.root.join("spec/factories/data/landing_call_failure.xml"))
        stub_request(:any, /.*localhost:8883.*/)
          .to_return(status: 200, body: raw_response_file, headers: { 'Content-Type' => 'application/xml;charset=utf-8' })
      end
      it "should not add call_sid" do
        Notification::Notifier.make_landing_call_to_phone(@receipt)
        record = @author.call_communication_records.first
        record.status.should_not be_blank
        record.call_sid.should be_blank
      end
    end
  end
  describe ".make_landing_call_to_phone_async" do
    before do
      ResqueSpec.reset!
    end
    it "should do notifier.publish_to_faye_client to youxin_notification_queue" do
      Notification::Notifier.make_landing_call_to_phone_async([@receipt].map(&:id))
      MakeLandingCallToPhoneJob.should have_queued([@receipt].map(&:id)).in(:youxin_notification_queue)
    end
  end

end
