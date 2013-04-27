require 'spec_helper'

describe "Avatar" do
  let(:user) { 
    avatar_path = Rails.root.join("spec/factories/images/avatar.png")
    user = create :user, avatar: Rack::Test::UploadedFile.new(avatar_path)
  }
  describe "GET avatar_url" do
    it "works" do
      get(user.avatar.url)
      response.status.should be(200)
    end
  end
end

