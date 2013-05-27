require 'spec_helper'

describe Comment do
  let(:comment) { build :comment }
  subject { comment }

  describe "Association" do
    it { should belong_to(:commentable) }
    it { should belong_to(:user) }
  end

  describe "Respond to" do
    it { should respond_to(:body) }
  end

  describe "#create" do
    before(:each) do
      @organization = create :organization
      @author = create :user
      @post = create :post, author: @author, organization_ids: [@organization.id]
    end

    context "successed" do
      it "with commentable" do
        @comment = @post.comments.create attributes_for(:comment)
        @comment.commentable.id.should == @post.id
        @comment.commentable.class.should == Post
      end

      it "with commentable_id and commentable_type" do
        @comment = Comment.create attributes_for(:comment).merge({
          commentable_id: @post.id, commentable_type: @post.class
        })
        @comment.should be_valid
      end
    end

    context "fail" do
      it "when blank body" do
        @comment = @post.comments.create body: '  '
        @comment.should have(1).error_on(:body)
      end
      it "when not given commentable" do
        @comment = Comment.create attributes_for(:comment)
        @comment.should have(1).error_on(:commentable_id)
        @comment.should have(1).error_on(:commentable_type)
      end
    end
  end

  describe "#commentable" do
    before(:each) do
      @organization = create :organization
      @author = create :user
      @post = create :post, author: @author, organization_ids: [@organization.id]
    end

    it "should return correct commentable" do
      @comment = @post.comments.create attributes_for(:comment)
      @comment.commentable.should == @post
    end

  end

end
