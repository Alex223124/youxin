require 'spec_helper'

describe AttachmentsController do
  include ApiHelpers

  before(:each) do
    @user = create :user
    @user_another = create :user
    @admin = create :user
    @organization = create :organization

    @organization.add_member(@user)
    @actions = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@admin, @actions)

    @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
    @file = Rack::Test::UploadedFile.new(@file_path, 'text/plain')

    attrs = attributes_for(:post).merge({
      organization_ids: [@organization.id],
    })
    @post = @admin.posts.create attrs
    @attachment = @admin.file_attachments.create(storage: @file)
    @post.attachments << @attachment
    @attachment.reload
  end
  it "should return 200 when attachment belongs to post" do
    get 'show', id: @attachment.id, private_token: @user.private_token
    response.status.should == 200
  end
  it "should return 200 when attachment belongs to user" do
    get 'show', id: @attachment.id, private_token: @admin.private_token
    response.status.should == 200
  end
  it "should return 404" do
    get 'show', id: @attachment.id, private_token: @user_another.private_token
    response.status.should == 404
  end
end