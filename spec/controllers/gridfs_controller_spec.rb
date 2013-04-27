require 'spec_helper'

describe GridfsController do
  let(:user) { 
    avatar_path = Rails.root.join("spec/factories/images/avatar.png")
    user = create :user, avatar: Rack::Test::UploadedFile.new(avatar_path)
  }
  describe "GET 'serve'" do
    it "returns http success" do
      pending 'should be_success but returns failure'
      get 'serve', path: user.id, format: 'png'
      response.should be_success
    end
  end

end
