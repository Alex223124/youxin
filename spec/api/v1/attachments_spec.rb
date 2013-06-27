require 'spec_helper'

describe Youxin::API, 'attachments' do
  include ApiHelpers

  before(:each) do
    @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
    @file = Rack::Test::UploadedFile.new(@file_path, 'text/plain')
    @image_path = Rails.root.join("spec/factories/data/attachment_image.png")
    @image = Rack::Test::UploadedFile.new(@image_path, 'image/png')
    @admin = create :user
    @organization = create :organization
    @actions = Action.options_array_for(:youxin)

    @organization.authorize(@admin, @actions)
  end

  describe "POST /attachments" do
    it "should create file attachment" do
      expect {
        post api('/attachments', @admin), { file: @file }
      }.to change { @admin.attachments.count }.by(1)
    end
    it "should return the details of file attachment" do
      post api('/attachments', @admin), { file: @file }
      json_response['id'].should_not be_nil
      json_response['file_name'].should == 'attachment_file.txt'
      json_response['file_size'].to_i.should == @file.size
      json_response['file_type'].should == 'text/plain'
      json_response['image'].should be_false
      json_response['url'].should == "/attachments/#{json_response['id']}"
    end

    it "should create image attachment" do
      expect {
        post api('/attachments', @admin), { file: @image }
      }.to change { @admin.attachments.count }.by(1)
    end
    it "should return the details of image attachment" do
      post api('/attachments', @admin), { file: @image }
      json_response['id'].should_not be_nil
      json_response['file_name'].should == 'attachment_image.png'
      json_response['file_type'].should == 'image/png'
      json_response['image'].should be_true
      json_response['url'].should == "/attachments/#{json_response['id']}"
    end
  end

end