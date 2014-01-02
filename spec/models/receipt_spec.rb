require 'spec_helper'

describe Receipt do
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
    it { should have_many(:favorites) }
    it { should have_many(:communication_records) }
    it { should have_many(:sms_communication_records) }
    it { should have_many(:call_communication_records) }
  end

  describe "Respond to" do
    it { should respond_to(:organizations) }
    it { should respond_to(:read) }
    it { should respond_to(:read!) }
    it { should respond_to(:read_at) }
    it { should respond_to(:origin) }
    it { should respond_to(:short_key) }
    it { should respond_to(:forms_filled) }
    it { should respond_to(:short_url) }
    it { should respond_to(:archived) }
    it { should respond_to(:archive!) }
    it { should respond_to(:unarchive!) }
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

  describe "#ensure_short_key!" do
    before(:each) do
      @author = create :user
      @user = create :user
      @organization = create :organization
      @organization.add_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
      @receipt = @user.receipts.first
    end
    it "should have short_key" do
      @receipt.short_key.should_not be_nil
    end
    it "should ensure short_key unique" do
      another_user = create :user
      another_receipt = build :receipt, post: @post, user: another_user, short_key: @receipt.short_key
      another_receipt.save
      another_receipt.short_key.should_not == @receipt.short_key
    end
  end

  describe '#short_url' do
    before(:each) do
      @author = create :user
      @user = create :user
      @organization = create :organization
      @organization.add_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
      @receipt = @user.receipts.first
    end
    it 'should return the short_url' do
      @receipt.short_url.should == "#{Youxin.config.shorten_server}/#{@receipt.short_key}"
    end
  end

  describe '#archived' do
    before(:each) do
      @author = create :user
      @user = create :user
      @organization = create :organization
      @organization.add_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
      @receipt = @user.receipts.first
    end
    it 'should return archived status' do
      @receipt.archived.should == false
    end
    context '#archive!' do
      it 'should archive the receipt' do
        expect {
          @receipt.archive!
        }.to change { @receipt.archived }
      end
      it 'should not display the archived receipts' do
        @receipt.archive!
        @user.reload
        @user.receipts.unarchived.should_not include(@receipt)
      end
      it 'should read the receipt' do
        @receipt.archive!
        @receipt.read.should be_true
      end
    end
    context '#unarchive!' do
      before(:each) do
        @receipt.archive!
      end
      it 'should unarchive the receipt' do
        @receipt.unarchive!
        @receipt.archived.should be_false
      end
    end
  end

end
