# encoding: utf-8

require 'spec_helper'

describe Youxin::Util do
  context '#generate_random_string' do
    it 'should generate random string' do
      Youxin::Util.generate_random_string.length.should == 8
    end
  end
  context '#badiu_push_client' do
    it 'should not raise error' do
      Youxin::Util.baidu_push_client
    end
  end
end
