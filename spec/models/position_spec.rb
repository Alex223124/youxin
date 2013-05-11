require 'spec_helper'

describe Position do
  let(:position) { build :position }
  subject { position }

  it "should create a new instance given a valid attributes" do
    expect(build :position).to be_valid
  end

  describe "Respond to" do
    it { should respond_to(:name) }
  end

end
