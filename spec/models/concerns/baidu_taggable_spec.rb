require 'spec_helper'

describe BaiduTaggable do
  class Monkey
    include Mongoid::Document
    include Mongoid::Paranoia
    include Mongoid::Timestamps
    include BaiduTaggable

    belongs_to :user

    def baidu_push_users
      [self.user]
    end
  end

  let(:namespace) { create :namespace }
  let(:user) { create :user, namespace: namespace }
  let(:monkey) { Monkey.new user_id: user.id }
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
      monkey.baidu_push_users.map(&:set_up_tags)

      stub_request(:any, /.*channel\.api\.duapp\.com.*/)
        .to_return(status: 200, body: 'aa', headers: { 'Content-Type' => 'application/json;charset=utf-8' })
    end

    it 'should add new tag to user' do
      monkey.reset_tag!
      monkey.baidu_push_users.first.tags.should include(monkey.tag)
    end

    it 'should not generate new tag' do
      old_tag = monkey.tag
      monkey.reset_tag!
      monkey.reload
      monkey.tag.should_not == old_tag
    end

    it 'should remove tag from baidu_push_users' do
      old_tag = monkey.tag
      monkey.reset_tag!
      monkey.baidu_push_users.first.tags.should_not include(old_tag)
    end
  end
end

