require 'spec_helper'

describe User do
  let(:user) { build :user }
  subject { user }

  describe "Association" do
    it { should have_many(:user_organization_position_relationships) }
    it { should have_many(:user_actions_organization_relationships) }
    it { should have_many(:applications) }
    it { should have_many(:treated_applications) }
    it { should have_many(:posts) }
    it { should have_many(:receipts) }
    it { should have_many(:attachments) }
    it { should have_many(:forms) }
    it { should have_many(:collections) }
    it { should have_many(:comments) }
    it { should have_many(:favorites) }
    it { should have_many(:notifications) }
    it { should have_many(:comment_notifications) }
    it { should have_many(:organization_notifications) }
  end

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:organization_ids) }
    it { should respond_to(:organizations) }
    it { should respond_to(:position_in_organization) }
    it { should respond_to(:human_position_in_organization) }
    it { should respond_to(:authorized_organizations) }
    it { should respond_to(:apply_for_organization) }
    it { should respond_to(:applied_for_organization?) }
    it { should respond_to(:accepted_by_organization?) }
    it { should respond_to(:operate_application) }
    it { should respond_to(:receipt_organizations) }
    it { should respond_to(:receipt_users) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :user).to be_valid
  end

  describe "#organizations" do
    before do
      @organization = create :organization
      @user = create :user
    end
    it "should return correctly" do
      @organization.push_member(@user)
      @user.organizations.include?(@organization).should be_true
    end
  end
  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#apply_for_organization" do
    before(:each) do
      @user = create :user
      @organization = create :organization
    end
    it "should create a new applications for organization" do
      @user.apply_for_organization(@organization)
      @user.applications.should_not be_blank
    end
    it "should create a new applications for organization with id" do
      @user.apply_for_organization(@organization.id)
      @user.applications.should_not be_blank
    end
    it "should do nothing organization not exist" do
      @user.apply_for_organization('not_exist')
      @user.applications.should be_blank
    end
  end
  describe "#applied_for_organization?" do
    before(:each) do
      @user = create :user
      @organization = create :organization
    end
    it "should return true if user have applied for the organization" do
      @user.apply_for_organization(@organization)
      @user.applied_for_organization?(@organization).should be_true
    end
    it "should return false if user have not applied for the organization" do
      @user.applied_for_organization?(@organization).should be_false
    end
    it "should return true if user have applied for the organization with id" do
      @user.apply_for_organization(@organization.id)
      @user.applied_for_organization?(@organization).should be_true
    end
    it "should return false if user have not applied for the organization with id" do
      @user.applied_for_organization?(@organization.id).should be_false
    end
  end
  describe "#accepted_by_organization?" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @operator = create :user
    end
    it "should accepted by organization" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
    end
    it "should not accepted by organization" do
      @user.apply_for_organization(@organization)
      @user.accepted_by_organization?(@organization).should be_false
    end
    it "should accepted by organization with id" do
      application = @user.apply_for_organization(@organization.id)
      @operator.operate_application(application, :accepted)
      @user.reload.accepted_by_organization?(@organization.id).should be_true
    end
    it "should not accepted by organization with id" do
      @user.apply_for_organization(@organization)
      @user.accepted_by_organization?(@organization.id).should be_false
    end
  end
  describe "#operate_application" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @operator = create :user
    end
    it "should accept user" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
      @user.accepted_by_organization?(@organization).should be_true
    end
    it "should not accept user" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :rejected)
      @user.accepted_by_organization?(@organization).should be_false
    end
    it "should be the member of organization" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
      @organization.members.should include(@user)
    end
    it "should have a operator" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
      @operator.treated_applications.should include(application)
    end
  end

  describe "#authorized_organizations" do
    before(:each) do
      @organization1 = create :organization
      @organization2 = create :organization
      @organization3 = create :organization
      @user = create :user
      @actions1 = Action.options_array_for(:organization)
      @actions2 = Action.options_array_for(:youxin)
      @organization1.authorize(@user, @actions1)
      @organization2.authorize(@user, @actions2)
      @organization3.authorize(@user, @actions1 + @actions2)
    end
    it "should return the array of authorized organizations" do
      @user.authorized_organizations.should include(@organization1)
      @user.authorized_organizations.should include(@organization2)
      @user.authorized_organizations.should include(@organization3)
    end
    it "should return the array of authorized organizations with actions" do
      @user.authorized_organizations([:create_organization]).should include(@organization1)
      @user.authorized_organizations([:create_organization]).should include(@organization3)
      @user.authorized_organizations([:create_youxin]).should include(@organization2)
      @user.authorized_organizations([:create_youxin]).should include(@organization3)
      @user.authorized_organizations([:create_youxin, :create_organization]).should include(@organization3)
    end
  end

  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#destroy" do
    before do
      @organization = create :organization
      @user = create :user
      @organization.push_member(@user)
    end
    it "should remove organizations" do
      @user.destroy
      @user.organizations.should be_blank
    end
    it "should remove user from organization" do
      @user.destroy
      @organization.reload.member_ids.include?(@user.id).should be_false
    end
  end

  describe "invalid attributes" do
    context "name" do
      context "is blank" do
        before { user.name = '' }
        its(:valid?) { should be_false }
      end
    end

    context "avatar" do
      it "return url of avatar" do
        avatar_path = Rails.root.join("spec/factories/images/avatar.png")
        user = create :user, avatar: Rack::Test::UploadedFile.new(avatar_path)
        user.avatar.file.should_not be_blank
        user.avatar.url.should_not be_blank
        user.avatar.url.should == "/uploads/avatar/user/#{user.id}.png"
      end
    end
  end

  describe "#update_with_password" do
    context "without password" do
      before do
        user.save
        user.update_with_password name: 'name-modify'
        user.reload
      end
      its(:name) { should == 'name-modify' }
    end

    context "with password" do
      before do
        user.save
        user.update_with_password name: 'name-modify', password: 'invalid_password'
        user.reload
      end
      its(:name) { should_not == 'name-modify' }
    end
  end

  describe "#receipts" do
    before(:each) do
      @organization = create :organization
      @organization_another = create :organization
      @user = create :user
      @author = create :user
      @author_another = create :user
      @organization.push_member(@user)
      @organization_another.push_member(@user)
      @post = create(:post, author: @author,
                            organization_ids: [@organization.id])
      @post_another = create(:post, author: @author_another,
                                    organization_ids: [@organization_another.id])
    end
    context "from_users(:user_id)" do
      it "should return receipts which from single user" do
        @user.receipts.from_users(@author.id).map(&:id).should include(@user.receipts.last.id)
      end
      it "should not include receipts which not from single user" do
        @user.receipts.from_users(@author.id).map(&:id).should_not include(@user.receipts.first.id)
        @user.receipts.from_users(@author_another.id).map(&:id).should_not include(@user.receipts.last.id)
      end
    end
    context "from_organizations(:organization_id)" do
      it "should return receipts from single organization" do
        @user.receipts.from_organizations(@organization.id).map(&:id).should include(@user.receipts.last.id)
      end
      it "should not include receipts which not from single organization" do
        @user.receipts.from_organizations(@organization.id).map(&:id).should_not include(@user.receipts.first.id)
      end
    end
    context "read" do
      it "should create" do
        @author.receipts.read.first.post.should == @post
      end
    end
    context "unread" do
      it "should not create" do
        @author.receipts.unread.should be_blank
      end      
    end
  end

  describe "#comments" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should create comment" do
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @comment.should be_valid
    end
  end
  describe "#receipt_organizations" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should return the array of organizations which have send post to user" do
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @user.reload
      ([@organization] - @user.receipt_organizations).should be_blank
    end
  end
  describe "#receipt_users" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should return the array of users which have send post to user" do
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @user.reload
      ([@author] - @user.receipt_users).should be_blank
    end
  end

  describe "#favorites" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
      @receipt = @user.receipts.first
    end
    it "should create favorite" do
      @receipt.favorites.create user_id: @user.id
      @user.favorites.count.should == 1
      @user.favorites.receipts.pluck(:favoriteable_id).should include(@receipt.id)
    end
  end


end
