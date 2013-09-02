# encoding: utf-8

require 'spec_helper'

describe CommunicationRecord::Sms do
  let(:sms_communication_record) { build :sms_communication_record }
  subject { sms_communication_record }

  describe "Respond to" do
    it { should respond_to(:human_status) }
  end

  describe "#human_status" do
    it "should return the human_status" do
      sms_communication_record.status = '0'
      sms_communication_record.human_status.should == '发送成功'
    end
    it "should return unknow error" do
      sms_communication_record.status = 'unknow'
      sms_communication_record.human_status.should == '未知错误'
    end
  end
end
