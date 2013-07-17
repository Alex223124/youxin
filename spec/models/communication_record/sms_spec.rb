# encoding: utf-8

require 'spec_helper'

describe CommunicationRecord::Sms do
  let(:sms_communication_record) { build :sms_communication_record }
  subject { sms_communication_record }

  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:receipt) }
  end

  describe "Respond to" do
    it { should respond_to(:status) }
    it { should respond_to(:human_status) }
  end

  before(:each) do
    @author = create :user
    user = create :user
    organization = create :organization
    organization.add_member(user)
    post = create :post, author: @author, organization_ids: [organization].map(&:id)
    @receipt = create :receipt, post: post, user: user
  end

  describe "#user" do
    before(:each) do
      sms_communication_record.receipt_id = @receipt.id
      sms_communication_record.status = 0
    end
    it "should reference to user" do
      sms_communication_record.save
      sms_communication_record.user.should == @author
    end
    it "should add communication_record to author" do
      expect{
        sms_communication_record.save
      }.to change(@author.sms_communication_records, :count).by(1)
    end
  end
  describe "#human_status" do
    it "should return the correct one" do
      sms_communication_record.receipt_id = @receipt.id
      sms_communication_record.status = '0'
      sms_communication_record.save
      sms_communication_record.human_status.should == "短信发送成功"
    end
  end
end
