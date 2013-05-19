require 'spec_helper'

describe Receipt do
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe "Respond to" do
    it { should respond_to(:organizations) }
    it { should respond_to(:read) }
    it { should respond_to(:read!) }
    it { should respond_to(:read_at) }
    it { should respond_to(:origin) }
  end

  describe "#author" do
    before(:each) do
      @author = create :user
      @user = create :user
      @organization = create :organization
      @organization.add_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
      @receipt = create :receipt, post: @post, user: @user
    end
    it "should return to the author" do
      @receipt.author.should == @author
    end
  end

  describe "#read!" do
    before(:each) do
      @author = create :user
      @user = create :user
      @organization = create :organization
      @organization.add_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
      @receipt = create :receipt, post: @post, user: @user
    end
    it "should update update_at" do
      receipt = @user.receipts.first
      receipt.read!
      receipt.read_at.should_not be_nil
    end
  end
end
