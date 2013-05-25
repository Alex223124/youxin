require 'spec_helper'

describe Field::TextField do
  let(:text_field) { build :text_field }
  subject { text_field }
  describe "Association" do
    it { should belong_to(:form) }
  end

  describe "Respond to" do
    it { should respond_to(:default_value) }
  end
end