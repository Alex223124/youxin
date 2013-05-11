require 'spec_helper'

describe Action do

  describe :options do
    it "should return the options of action" do
      Action.options.should_not be_nil
    end
    it "should return the hash" do
      Action.options.should be_a_kind_of Hash
    end
  end

  describe "#options_array" do
    it "should return the array" do
      Action.options_array.should be_a_kind_of Array
    end
    it "should return the array composed of option" do
      Action.options.each_key do |k|
        Action.options_array.should include(k)
      end
    end
  end

  describe "#options_for" do
    it "item in actions" do
      %w(organization user youxin).each do |item|
        Action.options_for(item).should == Action.send(item)
      end
    end
    it "item not in actions" do
      Action.options_for('not_in').should == {}
    end
  end

  describe "#options_array_for" do
    it "item in actions" do
      %w(organization user youxin).each do |item|
        Action.options_array_for(item).should == Action.send(item).collect { |k, v| k }
      end
    end
    it "item not in actions" do
      Action.options_array_for('not_in').should == []
    end
  end

  describe "#to_human" do
    it "should return human_string of action" do
      option = Action.options.first
      Action.to_human(option.first).should == option.last
    end
  end

end