require 'spec_helper'

describe Receipt do
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
    it { should have_many(:favorites) }
    it { should have_many(:sms_communication_records) }
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
    it "should update read_at" do
      receipt = @user.receipts.first
      receipt.read!
      receipt.read_at.should_not be_nil
    end
    it "should mark as read" do
      receipt = @user.receipts.first
      receipt.read!
      receipt.read.should be_true
    end
  end

  describe "#favorites" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @receipt = @user.receipts.first
    end

    it "should create a favorite" do
      @favorite = @receipt.favorites.create attributes_for(:favorite).merge({ user_id: @user.id })
      @favorite.should be_valid
    end

    it "should return the array of favorites" do
      @receipt.favorites.create attributes_for(:favorite), user_id: @user.id
      @receipt.favorites.should be_kind_of Array
      @receipt.favorites.each do |favorite|
        favorite.should be_kind_of Favorite
      end
    end
  end

end
