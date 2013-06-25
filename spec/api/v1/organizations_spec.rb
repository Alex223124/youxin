require 'spec_helper'

describe Youxin::API, 'organizations' do
  include ApiHelpers

  describe "GET /organizations/:id" do
    before(:each) do
      @user = create :user
      @author = create :user
      @organization = create :organization
      @organization.push_member(@user)
    end
    context "/" do
      it "should return single organization" do
        get api("/organizations/#{@organization.id}", @user)
        response.status.should == 200
        json_response.should == {
          id: @organization.id,
          name: @organization.name,
          parent_id: @organization.parent_id,
          created_at: @organization.created_at,
          avatar: @organization.avatar.url
        }.as_json
      end
    end

    context "/members" do
      it "should return the members of single organization" do
        @user_another = create :user
        @organization.push_members([@user, @user_another])
        get api("/organizations/#{@organization.id}/members", @user)
        response.status.should == 200
        json_response.should == [
          {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            created_at: @user.created_at,
            avatar: @user.avatar.url
          },
          {
            id: @user_another.id,
            email: @user_another.email,
            name: @user_another.name,
            created_at: @user_another.created_at,
            avatar: @user_another.avatar.url
          }
        ].as_json
      end
    end

    context "/receipts" do
      it "should return the receipts from single organization" do
        post = create :post, author: @author, organization_ids: [@organization].map(&:id)
        @receipt = @user.receipts.first
        get api("/organizations/#{@organization.id}/receipts", @user)
        response.status.should == 200
        json_response.should == [
          {
            id: @receipt.id,
            read: @receipt.read,
            favorited: false,
            origin: @receipt.origin,
            organizations: [
              {
                id: @organization.id,
                name: @organization.name,
                parent_id: @organization.parent_id,
                created_at: @organization.created_at,
                avatar: @organization.avatar.url
              }
            ],
            post: {
              id: @receipt.post.id,
              title: @receipt.post.title,
              body: @receipt.post.body,
              body_html: @receipt.post.body_html,
              created_at: @receipt.post.created_at,
              author: {
                id: @receipt.author.id,
                email: @receipt.author.email,
                name: @receipt.author.name,
                created_at: @receipt.author.created_at,
                avatar: @receipt.author.avatar.url
              },
              attachments: [],
              forms: []
            }
          }
        ].as_json
      end
    end

    context "/unread_receipts" do
      it "should return the unread receipts from single organization" do
        post_1 = create :post, author: @author, organization_ids: [@organization].map(&:id)
        post_2 = create :post, author: @author, organization_ids: [@organization].map(&:id)
        @receipt_1 = post_1.receipts.where(user_id: @user.id).first
        @receipt_2 = post_2.receipts.where(user_id: @user.id).first
        @receipt_1.read!
        get api("/organizations/#{@organization.id}/unread_receipts", @user)
        response.status.should == 200
        json_response.should == [
          id: @receipt_2.id,
          read: @receipt_2.read,
          favorited: false,
          origin: @receipt_2.origin,
          organizations: [
            {
              id: @organization.id,
              name: @organization.name,
              parent_id: @organization.parent_id,
              created_at: @organization.created_at,
              avatar: @organization.avatar.url
            }
          ],
          post: {
            id: @receipt_2.post.id,
            title: @receipt_2.post.title,
            body: @receipt_2.post.body,
            body_html: @receipt_2.post.body_html,
            created_at: @receipt_2.post.created_at,
            author: {
              id: @receipt_2.author.id,
              email: @receipt_2.author.email,
              name: @receipt_2.author.name,
              created_at: @receipt_2.author.created_at,
              avatar: @receipt_2.author.avatar.url
            },
            attachments: [],
            forms: []
          }
        ].as_json
      end
    end

  end
end