require 'spec_helper'

describe Field::CheckBox do
  let(:check_box) { build :check_box }
  subject { check_box }
  describe "Association" do
    it { should belong_to(:form) }
    it { should embed_many(:options) }
  end

  describe "#create" do
    context "can select many options" do
      it "successfully" do
        @check_box = build :check_box
        @option_1 = build :option, default_selected: true
        @option_2 = build :option, default_selected: true
        @option_3 = build :option
        @check_box.options << @option_1
        @check_box.options << @option_2
        @check_box.options << @option_3
        @check_box.save
        @check_box.should be_valid
        @check_box.options.count.should == 3
      end
    end
  end
end