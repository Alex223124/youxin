require 'spec_helper'

describe Lite::ReceiptsController do
  let(:namespace) { create :namespace }
  let(:admin) { create :user, namespace: namespace }
  let(:user) { create :user, namespace: namespace }
  let(:organization) { create :organization, namespace: namespace }

  describe "GET 'index'" do
    before(:each) do
      organization.pull_members [admin, user]
      post = create :post, author_id: admin.id, organization_ids: [organization.id]
      @receipt = user.receipts.first
      login_user user
    end
    it "returns http success" do
      get :index
      response.should be_success
    end
    it 'should return the receipts of current_use' do
      get :index
      assigns(:receipts).should == user.receipts
    end
  end

  describe "GET 'show'" do
    before(:each) do
      organization.add_members [admin, user]
      post = create :post, author_id: admin.id, organization_ids: [organization.id]
      @receipt = user.receipts.first
      login_user user
    end
    it "returns http success" do
      get :show, id: @receipt.id
      response.should be_success
    end
  end

end
