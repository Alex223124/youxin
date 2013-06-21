require 'spec_helper'

describe Youxin::API, 'helpers' do
  include ApiHelpers

  describe "paginate" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization = create :organization
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization.authorize_cover_offspring(@admin, @actions_youxin)
      @organization.push_member(@user)

      @post_1 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_2 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_3 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_4 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_5 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_6 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_7 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_8 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_9 = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @post_10 = create :post, author: @admin, organization_ids: [@organization].map(&:id)

      @receipt_1 = @user.receipts.where(post_id: @post_1.id).first
      @receipt_2 = @user.receipts.where(post_id: @post_2.id).first
      @receipt_3 = @user.receipts.where(post_id: @post_3.id).first
      @receipt_4 = @user.receipts.where(post_id: @post_4.id).first
      @receipt_5 = @user.receipts.where(post_id: @post_5.id).first
      @receipt_6 = @user.receipts.where(post_id: @post_6.id).first
      @receipt_7 = @user.receipts.where(post_id: @post_7.id).first
      @receipt_8 = @user.receipts.where(post_id: @post_8.id).first
      @receipt_9 = @user.receipts.where(post_id: @post_9.id).first
      @receipt_10 = @user.receipts.where(post_id: @post_10.id).first
    end
    describe "range" do
      it "should return the array of receipts" do
        get api('/user/receipts', @user)
        json_response.map { |e| e['id'] }.should == [@receipt_1, @receipt_2,
          @receipt_3, @receipt_4, @receipt_5, @receipt_6, @receipt_7,
          @receipt_8, @receipt_9, @receipt_10].reverse.map(&:id).as_json 
        end
      it "should return the array of receipts with range assign max_id" do
        get api('/user/receipts', @user), max_id: @receipt_2.id
        json_response.map { |e| e['id'] }.should == [@receipt_1].map(&:id).as_json
      end
      it "should return the array of receipts with range assign since_id" do
        get api('/user/receipts', @user), since_id: @receipt_9.id
        json_response.map { |e| e['id'] }.should == [@receipt_10].map(&:id).as_json
      end
      it "should return the array of receipts with range zero" do
        get api('/user/receipts', @user), since_id: @receipt_2.id, max_id: @receipt_3.id
        json_response.map { |e| e['id'] }.should == [].as_json
      end
      it "should return the array of receipts with range not zero" do
        get api('/user/receipts', @user), since_id: @receipt_2.id, max_id: @receipt_8.id
        json_response.map { |e| e['id'] }.should == [@receipt_7, @receipt_6,
          @receipt_5, @receipt_4, @receipt_3].map(&:id).as_json
      end
    end
    describe "paginate" do
      it "should return the array of receipts with paginate" do
        get api('/user/receipts', @user), per_page: 2, page: 2
        json_response.map { |e| e['id'] }.should == [@receipt_8, @receipt_7].map(&:id).as_json
      end
    end
  end
end