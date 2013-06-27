require 'spec_helper'

describe Field::Option do
  let(:option) { build :option }
  subject { option }
  describe "Association" do
    it { should be_embedded_in(:radio_button) }
    it { should be_embedded_in(:check_box) }
  end

  describe "Respond to" do
    it { should respond_to(:default_selected) }
    it { should respond_to(:value) }
  end

end