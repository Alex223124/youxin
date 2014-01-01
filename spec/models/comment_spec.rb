require 'spec_helper'

describe Comment do
  let(:comment) { build :comment }
  subject { comment }

  describe "Association" do
    it { should belong_to(:commentable) }
    it { should belong_to(:user) }
    it { should have_many(:comment_notifications) }
  end

  describe "Respond to" do
    it { should respond_to(:body) }
  end

  describe "#create" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization.id]
    end

    context "successed" do
      it "with commentable" do
        @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
        @comment.commentable.id.should == @post.id
        @comment.commentable.class.should == Post
      end

      it "with commentable_id and commentable_type" do
        @comment = Comment.create attributes_for(:comment).merge({
          commentable_id: @post.id, commentable_type: @post.class, user_id: @user.id
        })
        @comment.should be_valid
      end
    end

    context "fail" do
      it "when blank body" do
        @comment = @post.comments.create body: '  ', user_id: @user.id
        @comment.should have(1).error_on(:body)
      end
      it "when not given commentable" do
        @comment = Comment.create attributes_for(:comment)
        @comment.should have(1).error_on(:user_id)
        @comment.should have(1).error_on(:commentable_id)
        @comment.should have(1).error_on(:commentable_type)
      end
    end

    context '#can_mention_user' do
      it 'should add user_id to can_mention_user_ids of commentable' do
        expect {
          @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
        }.to change { @post.can_mention_user_ids.count }.by(1)
      end
      it 'should not add the id of author to can_mention_user_ids of commentable' do
        expect {
          @post.comments.create attributes_for(:comment).merge({ user_id: @author.id })
        }.to change { @post.can_mention_user_ids.count }.by(0)
      end
    end
  end

  describe '#destroy' do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
    end
    context '#can_mention_user' do
      it 'should add user_id to can_mention_user_ids of commentable' do
        expect {
          @comment.destroy
        }.to change { @post.can_mention_user_ids.count }.by(-1)
      end
    end
  end

  describe "#commentable" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @organization.push_member(@user)
      @author = create :user
      @post = create :post, author: @author, organization_ids: [@organization.id]
    end

    it "should return correct commentable" do
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @comment.commentable.should == @post
    end
  end

end
