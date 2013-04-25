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
  end
end
