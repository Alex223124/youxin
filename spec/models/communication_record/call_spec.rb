# encoding: utf-8

require 'spec_helper'

describe CommunicationRecord::Call do
  let(:call_communication_record) { build :call_communication_record }
  subject { call_communication_record }

  describe "Respond to" do
    it { should respond_to(:human_status) }
    it { should respond_to(:call_sid) }
  end

  describe "#human_status" do
    it "should return the human_status" do
      call_communication_record.status = '000000'
      call_communication_record.human_status.should == '请求成功'
    end
    it "should return unknow error" do
      call_communication_record.status = 'unknow'
      call_communication_record.human_status.should == '未知错误'
    end
  end
end
