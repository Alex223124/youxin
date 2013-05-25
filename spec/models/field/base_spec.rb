require 'spec_helper'

describe Field::Base do
  let(:field_base) { build :field_base }
  subject { field_base }
  describe "Association" do
    it { should belong_to(:form) }
  end

  describe "Respond to" do
    it { should respond_to(:label) }
    it { should respond_to(:help_text) }
    it { should respond_to(:required) }
    it { should respond_to(:identifier) }
  end

end