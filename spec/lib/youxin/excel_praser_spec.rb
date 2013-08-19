# encoding: utf-8

require 'spec_helper'

describe Youxin::ExcelPraser do
  let(:xlsx_file) {
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/factories/data/list.xlsx')
    )
  }
  let(:xls_file) {
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/factories/data/list.xls')
    )
  }

  describe "initialize" do
    let(:excel_praser) {
      Youxin::ExcelPraser.new(xls_file)
    }
    it "should return an instance of ExcelPraser" do
      excel_praser.should be_kind_of Youxin::ExcelPraser
    end

    it "should be properly initialized" do
      excel_praser.file.should == xls_file
      excel_praser.user_array.should be_kind_of Array
    end

    it "should respond to accessor" do
      excel_praser.should respond_to(:file)
      excel_praser.should respond_to(:worksheets)
      excel_praser.should respond_to(:user_array)
    end

     it "should respond to methods" do
       excel_praser.should respond_to(:process)
       excel_praser.should respond_to(:verify_file_type)
     end
  end

  describe "raise error" do
    it "file_type is not *.xls" do
      expect{
        Youxin::ExcelPraser.new(xlsx_file)
      }.to raise_error(Youxin::ExcelPraser::InvalidFileType)
    end
  end

  describe "#process" do
    let(:excel_praser) {
      Youxin::ExcelPraser.new(xls_file)
    }
    before do
      excel_praser.process
    end
    it "should return an array" do
      excel_praser.user_array.should be_kind_of Array
    end

    it "should return an array composed of user hash" do
      excel_praser.user_array.each do |user_hash|
        user_hash.should be_kind_of Hash
      end
    end

    it "should return user hash composed of name, email, phone" do
      excel_praser.user_array.each do |user_hash|
        user_hash.should have_key :name
        user_hash.should have_key :email
        user_hash.should have_key :phone
      end
    end

    it "should return correct user_array count" do
      excel_praser.user_array.count.should == 3
    end

    it "should return correct user_hash" do
      user_array = [ { name: '张三', email: 'zhangsan@y.x', phone: '18600000000'},
                     { name: '李四', email: 'lisi@y.x', phone: '18600000001'},
                     { name: '王五', email: 'wangwu@y.x', phone: '18600000002'} ]
      excel_praser.user_array.should == user_array
    end
  end
end
