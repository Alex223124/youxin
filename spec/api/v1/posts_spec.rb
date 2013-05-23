require 'spec_helper'

describe Youxin::API, 'posts' do
  include ApiHelpers

  before(:each) do
    @user = create :user
    @admin = create :user
    @organization = create :organization
    @organization_another = create :organization

    @organization.add_member(@user)
    @actions = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@admin, @actions)
    @organization.authorize_cover_offspring(@user, @actions)

    @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
    @file = Rack::Test::UploadedFile.new(@file_path)
    @image_path = Rails.root.join("spec/factories/data/attachment_image.png")
    @image = Rack::Test::UploadedFile.new(@image_path)
  end

  describe "POST /post" do
    it "should create post" do
      attrs = attributes_for(:post).merge!({
        organization_ids: [@organization].map(&:id)
      })
      expect {
        post api('/posts', @admin), attrs
      }.to change { Post.count }.by(1)
    end

    context "attachments" do
      it "should append attachments to post" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id)
        })
        attachment_ids = []
        post api('/attachments', @admin), { file: @file }
        attachment_ids << json_response['id']
        post api('/attachments', @admin), { file: @image }
        attachment_ids << json_response['id']

        attrs = attrs.merge({
          attachment_ids: attachment_ids
        })
        post api('/posts', @admin), attrs
        json_response['attachments'].should be_kind_of Array
        json_response['attachments'].first['id'].should == attachment_ids.first
        json_response['attachments'].last['id'].should == attachment_ids.last
      end

      it "should not append attachments if attachments does not belong to user" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id)
        })
        attachment_ids = []
        post api('/attachments', @user), { file: @file }
        attachment_ids << json_response['id']
        post api('/attachments', @admin), { file: @image }
        attachment_ids << json_response['id']

        attrs = attrs.merge({
          attachment_ids: attachment_ids
        })
        post api('/posts', @admin), attrs
        response.status.should == 400
        json_response['attachment_ids'].should_not be_nil
      end
    end
    context "when unauthorized organization" do
      it "should not create" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization, @organization_another].map(&:id)
        })
        post api('/posts', @admin), attrs
        response.status.should == 403
      end
    end
  end
end