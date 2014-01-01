require 'spec_helper'

describe Mentionable do
  class MonkeyDoc
    include Mongoid::Document
    include Mongoid::Paranoia
    include Mongoid::Timestamps
    include Mentionable

    field :body, type: String

    belongs_to :user

    def allow_mention_users
      super + commentable.can_mention_users - [user]
    end
  end

  let(:namespace) { create :namespace }
  let(:user) { create :user, namespace: namespace }
  let(:another_user) { create :user, namespace: namespace }
  let(:monkey_doc) { MonkeyDoc.create user_id: user.id, body: 'body' }

  subject { monkey_doc }

  before(:each) do
    MonkeyDoc.any_instance.stub_chain(:commentable, :can_mention_users).and_return([another_user])
  end

  describe 'Respond to' do
    it { should respond_to(:mentioned_user_ids) }
    it { should respond_to(:extract_mentioned_users) }
    it { should respond_to(:mentioned_users) }
    it { should respond_to(:create_mention_notifications) }
  end

  describe '#extract_mentioned_users' do
    it 'should extract mentioned user ids' do
      doc = MonkeyDoc.create user_id: user.id, body: "@#{another_user.name}"
      doc.mentioned_user_ids.should == [another_user.id]
    end
    it 'should not mention user self' do
      MonkeyDoc.any_instance.stub_chain(:commentable, :can_mention_users).and_return([another_user, user])
      doc = MonkeyDoc.create user_id: user.id, body: "@#{user.name}"
      doc.mentioned_user_ids.count.should == 0
    end
    it 'should be limited 3 mentioned user' do
      body = ""
      mention_users = [another_user]
      5.times do
        mention_users << FactoryGirl.create(:user)
        body << " @#{mention_users.last.name}"
      end

      MonkeyDoc.any_instance.stub_chain(:commentable, :can_mention_users).and_return(mention_users)
      doc = MonkeyDoc.create user_id: user.id, body: body
      doc.mentioned_user_ids.count.should == 3
    end
    it 'should exclude the author of post' do
      doc = MonkeyDoc.create user_id: another_user.id, body: "@#{user.name}"
      doc.mentioned_user_ids.should == []
    end
    it 'should not mention when not allowed' do
      user_three = create :user, namespace: namespace
      doc = MonkeyDoc.create user_id: another_user.id, body: "@#{user_three.name}"
      doc.mentioned_user_ids.should == []
    end
  end

  describe '#create_mention_notifications' do
    it 'should create mention notification' do
      expect {
        doc = MonkeyDoc.create user_id: user.id, body: "@#{another_user.name}"
      }.to change { another_user.mention_notifications.count }.by(1)
    end
    it 'should not create mention notification' do
      expect {
        doc = MonkeyDoc.create user_id: user.id, body: "@#{user.name}"
      }.to change { user.mention_notifications.count }.by(0)
    end
    it 'should not create mention notification when not allowed' do
      user_three = create :user, namespace: namespace
      expect {
        doc = MonkeyDoc.create user_id: user.id, body: "@#{user_three.name}"
      }.to change { user.mention_notifications.count }.by(0)
    end
  end

end
