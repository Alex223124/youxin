# encoding: utf-8

require 'spec_helper'

describe Youxin::Util do
  context 'generate_tag' do
    Youxin::Util.generate_random_string.length.should == 8
  end
end
