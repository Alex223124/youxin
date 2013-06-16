require 'spec_helper'

describe Favorite do
  let(:favorite) { build :favorite }
  subject { favorite }

  describe "Association" do
    it { should belong_to(:favoriteable) }
    it { should belong_to(:user) }
  end

  describe "Respond to" do
  end

  describe "#create" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @receipt = @post.receipts.first
    end

    context "successed" do
      it "with favoriteable" do
        @favorite = @receipt.favorites.create attributes_for(:favorite), user_id: @user.id
        @favorite.favoriteable.id.should == @receipt.id
        @favorite.favoriteable.class.should == Receipt
      end

      it "with favoriteable_id and favoriteable_type" do
        @favorite = Favorite.create attributes_for(:favorite).merge({
          favoriteable_id: @receipt.id, favoriteable_type: @receipt.class, user_id: @user.id
        })
        @favorite.should be_valid
      end
    end

    context "fail" do
      it "when not given favoriteable" do
        @favorite = Favorite.create attributes_for(:favorite)
        @favorite.should have(1).error_on(:user_id)
        @favorite.should have(1).error_on(:favoriteable_id)
        @favorite.should have(1).error_on(:favoriteable_type)
      end
      it "when have benn favorited" do
        @receipt.favorites.create user_id: @user.id
        @favorite = @receipt.favorites.create user_id: @user.id
        @favorite.should have(1).error_on(:favoriteable_id)
      end
    end
  end

  # describe "#commentable" do
  #   before(:each) do
  #     @organization = create :organization
  #     @author = create :user
  #     @post = create :post, author: @author, organization_ids: [@organization.id]
  #   end

  #   it "should return correct commentable" do
  #     @comment = @post.comments.create attributes_for(:comment)
  #     @comment.commentable.should == @post
  #   end

  # end

end
