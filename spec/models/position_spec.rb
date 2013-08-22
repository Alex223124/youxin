require 'spec_helper'

describe Position do
  let(:position) { build :position }
  subject { position }

  describe "Association" do
    it { should belong_to(:namespace) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :position).to be_valid
  end

  describe "Respond to" do
    it { should respond_to(:name) }
  end

  describe "Attributes" do
    before(:each) do
      @position = build :position
    end
    it "should not be valid" do
      @position.namespace_id = nil
      @position.should_not be_valid
    end
  end

end
