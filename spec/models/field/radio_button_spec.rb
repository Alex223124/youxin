require 'spec_helper'

describe Field::RadioButton do
  describe "Association" do
    it { should belong_to(:form) }
    it { should embed_many(:options) }
  end

  describe "Respond to" do
    # it { should respond_to(:) }
  end

  describe "#create" do
    context "only one can be selected" do
      before(:each) do
        @form = build :form
      end
      it "succeeds" do
        @radio_button = build :radio_button, form: @form
        @option_1 = build :option
        @option_2 = build :option
        @option_3 = build :option
        @radio_button.options << @option_1
        @radio_button.options << @option_2
        @radio_button.options << @option_3
        @radio_button.save
        @radio_button.should be_valid
        @radio_button.options.count.should == 3
      end
      it "fails when multi selected" do
        @radio_button = build :radio_button, form: @form
        @option_1 = build :option, default_selected: true
        @option_2 = build :option, default_selected: true
        @option_3 = build :option
        @radio_button.options = [@option_1, @option_2, @option_3]
        @radio_button.save
        @radio_button.should have(1).error_on(:options)
      end
      it "fails when duplicate options" do
        @radio_button = build :radio_button, form: @form
        @option = build :option
        @radio_button.options = [@option, @option]
        @radio_button.save
        @radio_button.should_not be_valid
      end
      it "fails when no options" do
        @radio_button = build :radio_button, form: @form
        @radio_button.save
        @radio_button.should_not be_valid
      end
    end
  end
end