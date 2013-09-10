require 'spec_helper'

describe BillingController do
  # include ApiHelpers
  include JsonParser

  let(:current_user) { create :user }
  let(:admin) { create :user }
  before(:each) do
    @organization = create :organization
    @organization.add_member(current_user)
    @post = create :post, author: admin, organization_ids: [@organization].map(&:id)
  end

  describe "GET sms" do
    before(:each) do
      login_user admin
      receipt = current_user.receipts.first
      admin.sms_communication_records.create status: '0', receipt: receipt
    end
    it 'should return 200' do
      get :sms
      response.status.should == 200
    end
    it 'should return rocords of sms' do
      get :sms
      json_response['sms_communication_records'].size.should == 1
    end
    it 'should return 0 records' do
      get :sms, start_date: '2012-10-10', end_date: '2012-11-11'
      json_response['sms_communication_records'].size.should == 0
    end
    it 'should raise error' do
      get :sms, start_date: '2012'
      response.status.should == 400
    end
  end
  describe "GET call" do
    before(:each) do
      login_user admin
      receipt = current_user.receipts.first
      admin.call_communication_records.create status: '000000', receipt: receipt
    end
    it 'should return 200' do
      get :call
      response.status.should == 200
    end
    it 'should return rocords of sms' do
      get :call
      json_response['call_communication_records'].size.should == 1
    end
    it 'should return 0 records' do
      get :call, start_date: '2012-10-10', end_date: '2012-11-11'
      json_response['call_communication_records'].size.should == 0
    end
    it 'should raise error' do
      get :call, start_date: '2012'
      response.status.should == 400
    end
  end
  describe 'GET bill_summary' do
    before(:each) do
      login_user admin
      receipt = current_user.receipts.first
      admin.sms_communication_records.create status: '0', receipt: receipt
    end
    it 'should return 200' do
      get :bill_summary
      response.status.should == 200
    end
    it 'should return rocords of sms' do
      get :bill_summary
      json_response['bill_summary'].should_not be_blank
      json_response['bill_summary']['sms'].should == 1
      json_response['bill_summary']['call'].should == 0
    end
    it 'should return 0 records' do
      get :bill_summary, month: '2012-10'
      json_response['bill_summary'].should_not be_blank
      json_response['bill_summary']['sms'].should == 0
      json_response['bill_summary']['call'].should == 0
    end
    it 'should raise error' do
      get :bill_summary, month: '2012'
      response.status.should == 400
    end
  end

end
