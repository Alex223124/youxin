require 'spec_helper'

describe Mentionable do
  class MonkeyDoc
    include Mongoid::Document
    include Mongoid::Paranoia
    include Mongoid::Timestamps
    include Mentionable

    field :body, type: String

    belongs_to :user
  end

  let(:namespace) { create :namespace }
  let(:user) { create :user, namespace: namespace }
  let(:monkey_doc) { MonkeyDoc.create user_id: user.id, body: 'body' }

  subject { monkey_doc }

  describe 'Respond to' do
    it { should respond_to(:mentioned_user_ids) }
    it { should respond_to(:extract_mentioned_users) }
    it { should respond_to(:mentioned_users) }
    it { should respond_to(:create_mention_notifications) }
  end

  describe '#extract_mentioned_users' do
    it 'should extract mentioned user ids' do
      another_user = create :user, namespace: namespace
      doc = MonkeyDoc.create user_id: user.id, body: "@#{another_user.name}"
      doc.mentioned_user_ids.should == [another_user.id]
    end
    it 'should mention user self' do
      doc = MonkeyDoc.create user_id: user.id, body: "@#{user.name}"
      doc.mentioned_user_ids.count.should == 0
    end
    it 'should be limited 3 mentioned user' do
      body = ""
      5.times { body << " @#{FactoryGirl.create(:user).name}" }
      doc = MonkeyDoc.create user_id: user.id, body: body
      doc.mentioned_user_ids.count.should == 3
    end
  end

  describe '#create_mention_notifications' do
    it 'should create mention notification' do
      another_user = create :user, namespace: namespace
      expect {
        doc = MonkeyDoc.create user_id: user.id, body: "@#{another_user.name}"
      }.to change { another_user.mention_notifications.count }.by(1)
    end
    it 'should not create mention notification' do
      expect {
        doc = MonkeyDoc.create user_id: user.id, body: "@#{user.name}"
      }.to change { user.mention_notifications.count }.by(0)
    end
  end

end
