require 'spec_helper'

describe Admin::UsersController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "POST 'excel_importor'" do
    let(:excel_file) do
      path = Rails.root.join('spec/factories/data/list.xls')
      file = Rack::Test::UploadedFile.new(path)
      file.stub(:tempfile).and_return(file)
      file
    end
    let(:invalid_file) do
      path = Rails.root.join('spec/factories/data/list.xlsx')
      file = Rack::Test::UploadedFile.new(path)
      file.stub(:tempfile).and_return(file)
      file
    end
    it "returns http success" do
      post 'excel_importor', excel: excel_file
      response.should be_redirect
    end

    it "should raise error with invalid file type" do
      request.env["HTTP_REFERER"] = new_admin_user_url
      post 'excel_importor', excel: invalid_file
      response.should redirect_to(:back)
    end

    it "should create 3 users" do
      excel_path = Rails.root.join('spec/factories/data/list.xls')
      expect { 
        post 'excel_importor', excel: excel_file
      }.to change(User, :count).by(3)
    end
  end

end
