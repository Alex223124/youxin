require 'spec_helper'

describe Entity do
  let(:entity) { build :entity }
  subject { entity }

  describe "Association" do
    it { should be_embedded_in(:collection) }
  end
  describe "Respond to" do
    it { should respond_to(:key) }
    it { should respond_to(:value) }
  end
end
