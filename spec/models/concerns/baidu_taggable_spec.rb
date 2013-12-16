require 'spec_helper'

describe BaiduTaggable do
  class Monkey
    include Mongoid::Document
    include Mongoid::Paranoia
    include Mongoid::Timestamps
    include BaiduTaggable
  end

  let(:monkey) { Monkey.new }
  subject { monkey }

  describe '#tag' do
    it 'should generate tag after save' do
      monkey.save
      monkey.reload
      monkey.tag.should_not be_blank
    end
  end

  describe '#ensure_tag' do
    it 'should generate tag' do
      monkey.ensure_tag
      monkey.tag.should_not be_blank
    end
  end
  describe '#ensure_tag!' do
    before(:each) do
      monkey.save
    end

    it 'should not generate new tag' do
      old_tag = monkey.tag
      monkey.ensure_tag!
      monkey.reload
      monkey.tag.should == old_tag
    end
  end
  describe '#reset_tag' do
    before(:each) do
      monkey.save
    end

    it 'should not generate new tag' do
      old_tag = monkey.tag
      monkey.reset_tag
      monkey.reload
      monkey.tag.should == old_tag
    end
  end
  describe '#reset_tag!' do
    before(:each) do
      monkey.save
    end

    it 'should not generate new tag' do
      old_tag = monkey.tag
      monkey.reset_tag!
      monkey.reload
      monkey.tag.should_not == old_tag
    end
  end
end

