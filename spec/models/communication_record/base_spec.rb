require 'spec_helper'

describe CommunicationRecord::Base do
  let(:base_communication_record) { build :base_communication_record }
  subject { base_communication_record }

  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:receipt) }
  end

  describe "Respond to" do
    it { should respond_to(:status) }
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
      base_communication_record.receipt_id = @receipt.id
      base_communication_record.status = 0
    end
    it "should reference to user" do
      base_communication_record.save
      base_communication_record.user.should == @author
    end
    it "should add communication_record to author" do
      expect{
        base_communication_record.save
      }.to change(@author.communication_records, :count).by(1)
    end
  end

  describe "#receipt" do
    before(:each) do
      base_communication_record.receipt_id = @receipt.id
      base_communication_record.status = 0
    end
    it "should add communication_record to receipt" do
      expect{
        base_communication_record.save
      }.to change(@receipt.communication_records, :count).by(1)
    end
  end
end
