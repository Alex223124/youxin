require 'spec_helper'

describe Mobile::ReceiptsController do
  let(:namespace) { create :namespace }
  let(:user) { create :user, namespace: namespace }
  let(:organization) { create :organization, namespace: namespace }
  let(:post) { create :post, author_id: user.id, organization_ids: [organization.id] }

  describe "GET 'index'" do
    it "returns http success" do
      login_user user
      get :index
      response.should be_success
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @receipt = create :receipt, post: post
      login_user user
    end
    it "returns http success" do
      get :show, id: @receipt.id
      response.should be_success
    end
  end

end
