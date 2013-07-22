require 'spec_helper'

describe Scheduler::Sms do
  before(:all) do
    Resque::Scheduler.mute = true
    Resque.redis.flushall
  end
  before(:each) do
    @user = create :user
    @organization = create :organization
    @author = create :user
    @organization.push_member(@user)
    @post = create :post, author: @author, organization_ids: [@organization.id]
    @timestamp = 1.day.from_now
  end
  describe "#create" do
    it "should be valid" do
      sms_scheduler = @post.sms_schedulers.new delayed_at: @timestamp
      sms_scheduler.should be_valid
    end
    it "should create an enqueue" do
      Resque.should_receive(:enqueue_at)
      sms_scheduler = @post.sms_schedulers.create delayed_at: @timestamp
    end
  end
  describe "enqueue" do
    it "should update ran_at after run" do
      sms_scheduler = @post.sms_schedulers.create delayed_at: Time.now
      pending 'update ran_at after handle_delayed_items'
      Resque::Scheduler.handle_delayed_items
      sms_scheduler.ran_at.should_not be_nil
    end
  end
  describe "#run_now!" do
    before(:each) do
      @scheduler = @post.sms_schedulers.create delayed_at: @timestamp
    end
    it "should delay to now" do
      Resque.should_receive(:enqueue_at)
      Resque.should_receive(:remove_delayed)
      @scheduler.run_now!
    end
    it "should update delayed_at" do
      expect { @scheduler.run_now! }.to change { @scheduler.delayed_at }
    end
  end
  describe "#destroy" do
    before(:each) do
      @scheduler = @post.sms_schedulers.create delayed_at: @timestamp
    end
    it "should destroy scheduler in Resque" do
      Resque.should_receive(:remove_delayed)
      @scheduler.destroy
    end
  end
end
