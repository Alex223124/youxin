require 'spec_helper'

describe Notification::Comment do
  let(:comment_notification) { build :notification_comment }
  subject { comment_notification }
  describe "Association" do
    it { should belong_to(:comment) }
  end
  describe "Respond to" do
    # it { should respond_to(:) }
  end

  before(:each) do
    @organization = create :organization
    @user = create :user
    @author = create :user
    @organization.push_member(@user)
    @post = create :post, author: @author, organization_ids: [@organization.id]
  end
  describe "#create" do
    it "should create comment_notification to author" do
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @author.comment_notifications.count.should == 1
    end
    it "should not create comment_notification to author when comment created by author" do
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @author.id })
      @author.comment_notifications.count.should == 0
    end
  end
  describe "#comment" do
    it "should return the correct comment" do
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @notification_comment = @author.comment_notifications.first
      @notification_comment.comment.should == @comment
    end
  end
end
