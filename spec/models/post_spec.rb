require 'spec_helper'

describe Post do
  let(:post) { build :post }
  subject { post }

  describe "Association" do
    it { should belong_to(:author) }
    it { should have_many(:receipts) }
    it { should have_many(:attachments) }
    it { should have_many(:forms) }
    it { should have_many(:comments) }
  end

  describe "Respond to" do
    it { should respond_to(:title) }
    it { should respond_to(:body) }
    it { should respond_to(:body_html) }
    it { should respond_to(:author) }
    it { should respond_to(:recipient_ids) }
    it { should respond_to(:recipients) }
    it { should respond_to(:organization_ids) }
    it { should respond_to(:organizations) }
    it { should respond_to(:organization_clans) }
    it { should respond_to(:organization_clan_ids) }
  end

  describe "#create" do
    #           C(*)---D---E
    #          /
    #  A(*)---B---F---G(*)
    #              \
    #               H---I
    # 
    before(:each) do
      @a = create :organization
      @b = create :organization, parent: @a
      @c = create :organization, parent: @b
      @d = create :organization, parent: @c
      @e = create :organization, parent: @d
      @f = create :organization, parent: @b
      @g = create :organization, parent: @f
      @h = create :organization, parent: @f
      @i = create :organization, parent: @h
      @author = create :user
      @user = create :user
    end
    it "should create a new instance given a valid attributes" do
      expect(build :post, author: @author, organization_ids: [@a.id]).to be_valid
    end
    it "should create receipts to members" do
      @a.push_member(@user)
      post = create :post, author: @author, organization_ids: [@a.id]
      @user.receipts.map(&:post).should include(post)
    end
    context "post from organizations" do
      before(:each) do
        @a.push_member(@user)
        @c.push_member(@user)
        @g.push_member(@user)
      end
      it "situation one" do
        organization_ids = Organization.all.map(&:id)
        post = create :post, author: @author, organization_ids: organization_ids
        @user.receipts.first.organization_ids.should == [@a].map(&:id)
        post.organization_ids.should == []
        post.organization_clan_ids.should == [@a.id]
      end
      it "situation two" do
        organization_ids = [@a, @c, @d, @e, @h].map(&:id)
        post = create :post, author: @author, organization_ids: organization_ids
        @user.receipts.first.organization_ids.should_not be_blank
        @user.receipts.first.organization_ids.delete_if do |id|
          [@a, @c, @h].map(&:id).include?(id)
        end.should be_blank
        post.organization_ids.delete_if do |id|
          [@a, @h].map(&:id).include?(id)
        end.should be_blank
        post.organization_clan_ids.delete_if do |id|
          [@c].map(&:id).include?(id)
        end.should be_blank
      end
      it "situation three" do
        organization_ids = [@a, @f, @g, @h].map(&:id)
        post = create :post, author: @author, organization_ids: organization_ids
        @user.receipts.first.organization_ids.delete_if do |id|
          [@a, @g].map(&:id).include?(id)
        end.should be_blank
        post.organization_ids.delete_if do |id|
          [@a, @f, @g, @h].map(&:id).include?(id)
        end.should be_blank
        post.organization_clan_ids.should be_blank
      end
      it "situation four" do
        organization_ids = [@a, @c, @g].map(&:id)
        post = create :post, author: @author, organization_ids: organization_ids
        @user.receipts.first.organization_ids.delete_if do |id|
          organization_ids.include?(id)
        end.should be_blank        
        post.organization_ids.delete_if do |id|
          [@a, @c, @g].map(&:id).include?(id)
        end.should be_blank
        post.organization_clan_ids.should be_blank
      end
      it "situation five" do
        organization_ids = [@a, @f, @g, @h, @i].map(&:id)
        post = create :post, author: @author, organization_ids: organization_ids
        @user.receipts.first.organization_ids.delete_if do |id|
          [@a, @f].map(&:id).include?(id)
        end.should be_blank
        post.organization_ids.delete_if do |id|
          [@a].map(&:id).include?(id)
        end.should be_blank
        post.organization_clan_ids.delete_if do |id|
          [@f].map(&:id).include?(id)
        end.should be_blank
      end
    end
    it "many recipients" do
      @a.push_member(@user)
      post = create :post, author: @author, organization_ids: [@a].map(&:id)
      post.recipients.should_not be_blank
    end
    it "recipients should not include author" do
      @a.push_members([@user, @author])
      post = create :post, author: @author, organization_ids: [@a].map(&:id)
      post.recipients.should_not include(@author)
    end
    it "should be in the receipts of author" do
      @a.push_members([@user, @author])
      post = create :post, author: @author, organization_ids: [@a].map(&:id)
      @author.receipts.first.post.should == post
    end
    it "should be in the receipts of author and mark read" do
      @a.push_members([@user, @author])
      post = create :post, author: @author, organization_ids: [@a].map(&:id)
      @author.receipts.first.read?.should be_true
    end
    it "should add organization_ids to the receipt of author" do
      @a.push_member(@user)
      post = create :post, author: @author, organization_ids: [@a].map(&:id)
      @author.receipts.first.organization_ids.should == [@a].map(&:id)            
    end
  end

  describe "#recipients" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should create a receipt for author" do
      @post.receipts.should include(@author.receipts.first)
    end
    it "should not include author" do
      @post.recipients.should_not include(@author)
    end
  end

  describe "#receipts" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    context "read" do
      it "should not include author" do
        @post.receipts.read.should_not include(@author.receipts.first)
      end
    end
    context "unread" do
      it "should not include author" do
        @post.receipts.unread.should_not include(@author.receipts.first)
      end      
    end
  end

  describe "invalid attributes" do
    before(:each) do
      @organization = create :organization
    end
    context "organization_ids" do
      it "blank" do
        post = build :post, organization_ids: []
        post.save
        post.should have(1).error_on(:organization_ids)
      end
    end
    context "body_html" do
      it "blank" do
        post = build :post, organization_ids: [@organization.id], body_html: ''
        post.save
        post.should have(1).error_on(:body_html)
      end
    end
  end
  describe "attributes" do
    before(:each) do
      @organization = create :organization
      @author = create :user
      @user = create :user
      @organization.push_member(@user)
    end
    it "should parse body_html to body" do
      body_html = "<div><h2>Head two</h2><p>hello test!</p></div>"
      post = create :post, author: @author, organization_ids: [@organization.id], body_html: body_html
      post.body.should == "Head twohello test!"
    end
  end

  describe "#comments" do
    before(:each) do
      @organization = create :organization
      @author = create :user
      @post = create :post, author: @author, organization_ids: [@organization.id]
    end

    it "should return the array of comments" do
      @post.comments.should be_kind_of Array
      @post.comments.each do |comment|
        comment.should be_kind_of Comment
      end
    end
  end

  describe "attachments" do
    before(:each) do
      @organization = create :organization
      @author = create :user
      @user = create :user
      @organization.push_member(@user)

      @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
      @file = Rack::Test::UploadedFile.new(@file_path, 'text/plain')
    end
    it "should append attachments" do
      attachments = [@author.file_attachments.create(storage: @file),
                     @author.file_attachments.create(storage: @file)]
      post = create :post, author: @author, organization_ids: [@organization.id]
      post.attachments += attachments
      post.attachments.count.should == 2
    end
    it "should append attachments" do
      post = create :post, author: @author, organization_ids: [@organization.id]
      post.attachments << @author.file_attachments.create(storage: @file)
      post.attachments.count.should == 1
    end
  end

end
