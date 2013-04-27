require 'spec_helper'

describe User do
  let(:user) { build :user }
  subject { user }

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :user).to be_valid
  end

  describe "invalid attributes" do
    context "name" do
      context "is blank" do
        before { user.name = '' }
        its(:valid?) { should be_false }
      end
    end

    context "avatar" do
      it "return url of avatar" do
        avatar_path = Rails.root.join("spec/factories/images/avatar.png")
        user = create :user, avatar: Rack::Test::UploadedFile.new(avatar_path)
        user.avatar.file.should_not be_blank
        user.avatar.url.should_not be_blank
        user.avatar.url.should == "/uploads/avatar/#{user.id}.png"
      end
    end
  end

  describe "#update_with_password" do
    context "without password" do
      before do
        user.save
        user.update_with_password name: 'name-modify'
        user.reload
      end
      its(:name) { should == 'name-modify' }
    end

    context "with password" do
      before do
        user.save
        user.update_with_password name: 'name-modify', password: 'invalid_password'
        user.reload
      end
      its(:name) { should_not == 'name-modify' }
    end
  end
end
