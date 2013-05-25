require 'spec_helper'

describe Field::NumberField do
  let(:number_field) { build :number_field }
  subject { number_field }
  describe "Association" do
    it { should belong_to(:form) }
  end

  describe "Respond to" do
    it { should respond_to(:default_value) }
  end

end