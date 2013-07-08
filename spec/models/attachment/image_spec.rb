require 'spec_helper'

describe Attachment::Image do
  after(:each) do
    Attachment::Image.all.map(&:storage).map(&:remove!)
  end
  describe "Respond to" do
    it { should respond_to(:file_name) }
    it { should respond_to(:file_type) }
    it { should respond_to(:file_size) }
    it { should respond_to(:dimension) }
    it { should respond_to(:image) }
    it { should respond_to(:details) }
  end

  describe "attributes" do
    before(:each) do
      @image_path = Rails.root.join("spec/factories/data/attachment_image.png")
      @image = Rack::Test::UploadedFile.new(@image_path, 'image/png')
      @attachment = create :attachment_image, storage: @image
    end
    it "should create an attachment" do
      @attachment.storage.url.should_not be_nil
    end
    it "should create file_name" do
      @attachment.file_name.should == 'attachment_image.png'
    end
    it "should change file_path" do
      @attachment.storage.file.path.should_not == Rails.root.join('public/attachments/attachment_image.png')
    end
    it "should set dimension" do
      image = MiniMagick::Image.open(@image_path)
      @attachment.dimension.should == "#{image[:width]},#{image[:height]}"
    end
  end

  describe "#details" do
    before(:each) do
      @file_path = Rails.root.join("spec/factories/data/attachment_image.png")
      @file = Rack::Test::UploadedFile.new(@file_path, 'image/png')
      @attachment = create :attachment_image, storage: @file
    end
    it "should return details hash" do
      size = File.size(@file_path)
      @attachment.details.should == {
                                      id: @attachment.id,
                                      file_name: 'attachment_image.png',
                                      file_type: 'image/png',
                                      file_size: size.to_s,
                                      url: "/attachments/#{@attachment.id}",
                                      versions: {
                                        thumb: @attachment.storage.url(:thumb),
                                        mobile: @attachment.storage.url(:mobile)
                                      }
                                    }
    end
  end

end