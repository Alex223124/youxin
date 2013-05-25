require 'spec_helper'

describe Field::TextArea do
  let(:text_area) { build :text_area }
  subject { text_area }
  describe "Association" do
    it { should belong_to(:form) }
  end

  describe "Respond to" do
    it { should respond_to(:default_value) }
  end

end