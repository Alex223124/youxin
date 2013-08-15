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
    @image_path = Rails.root.join("spec/factories/data/attachment_image.png")
    @image = Rack::Test::UploadedFile.new(@image_path, 'image/png')

    attrs = attributes_for(:post).merge({
      organization_ids: [@organization.id],
    })
    @post = @admin.posts.create attrs
    @attachment_file = @admin.file_attachments.create(storage: @file)
    @attachment_image = @admin.image_attachments.create(storage: @image)
    @post.attachments << @attachment_file
    @post.attachments << @attachment_image
    @attachment_file.reload
    @attachment_image.reload
  end
  it "should return 200 when attachment belongs to post" do
    get 'show', id: @attachment_file.id, private_token: @user.private_token
    response.status.should == 200
  end
  it "should return 200 when attachment belongs to user" do
    get 'show', id: @attachment_file.id, private_token: @admin.private_token
    response.status.should == 200
  end
  it "should return 403" do
    get 'show', id: @attachment_file.id, private_token: @user_another.private_token
    response.status.should == 403
  end
  context "image" do
    it "should return 200 when image_attachment exists" do
      get 'show', id: @attachment_image.id, private_token: @admin.private_token
      response.status.should == 200
    end
    it "should return 200 when verison exists" do
      get 'show', id: @attachment_image.id, private_token: @admin.private_token, version: :mobile
      response.status.should == 200
    end
    it "should return 404 when attachment not exist" do
      get 'show', id: 'not_exist', private_token: @admin.private_token
      response.status.should == 404
    end
    it "should return 404 when verison not exist" do
      get 'show', id: @attachment_image.id, private_token: @admin.private_token, version: :not_exist
      response.status.should == 404
    end
  end
end