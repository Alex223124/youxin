require 'spec_helper'

describe Attachment::File do
  after(:each) do
    Attachment::File.all.map(&:storage).map(&:remove!)
  end
  describe "Respond to" do
    it { should respond_to(:file_name) }
    it { should respond_to(:file_size) }
    it { should respond_to(:image) }
    it { should respond_to(:details) }
  end

  describe "attributes" do
    before(:each) do
      @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
      @file = Rack::Test::UploadedFile.new(@file_path)
      @attachment = create :attachment_file, storage: @file
    end
    it "should create an attachment" do
      @attachment.storage.url.should_not be_nil
    end
    it "should create file_name" do
      @attachment.file_name.should == 'attachment_file.txt'
    end
    it "should create file_size" do
      size = File.size(@file_path)
      @attachment.file_size.to_i.should == size
    end
    it "should change file_path" do
      @attachment.storage.file.path.should_not == Rails.root.join('public/attachments/attachment_file.txt').to_s
    end
  end

  describe "#details" do
    before(:each) do
      @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
      @file = Rack::Test::UploadedFile.new(@file_path)
      @attachment = create :attachment_file, storage: @file
    end
    it "should return details hash" do
      size = File.size(@file_path)
      @attachment.details.should == {
                                      file_name: 'attachment_file.txt',
                                      file_size: size.to_s,
                                      url: @attachment.storage.url
                                    }
    end
  end
end