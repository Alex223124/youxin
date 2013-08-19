require 'spec_helper'

describe CommentsController do
  include JsonParser

  let(:current_user) { create :user }
  let(:admin) { create :user }
  before(:each) do
    @parent = create :organization
    @current = create :organization, parent: @parent
    @parent.add_member(current_user)
    actions_youxin = Action.options_array_for(:youxin)
    @parent.authorize_cover_offspring(admin, actions_youxin)
    @post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
  end

  describe "GET 'index'" do
    before(:each) do
      login_user current_user
      3.times do
        @post.comments.create attributes_for(:comment).merge({ user_id: current_user.id })
      end
    end
    it "returns http success" do
      get :index, post_id: @post.id
      response.should be_success
    end
    it "should return the array of comments" do
      get :index, post_id: @post.id
      json_response['comments'].should be_a_kind_of(Array)
    end
    it "should return the comments" do
      get :index, post_id: @post.id
      json_response['comments'].size.should == 3
    end
  end

  describe "GET 'create'" do
    before(:each) do
      @valid_attrs = attributes_for :comment
      login_user current_user
    end
    it "should return 201" do
      post :create, post_id: @post.id, comment: @valid_attrs
      response.status.should == 201
    end
    it "should create a comment to post" do
      expect do
        post :create, post_id: @post.id, comment: @valid_attrs
      end.to change { @post.comments.count }.by(1)
    end
    it "should return 422" do
      @valid_attrs.delete(:body)
      post :create, post_id: @post.id, comment: @valid_attrs
      response.status.should == 422
    end
    it "should return 403" do
      another_user = create :user
      login_user another_user
      post :create, post_id: @post.id, comment: @valid_attrs
      response.status.should == 403
    end
  end

end
