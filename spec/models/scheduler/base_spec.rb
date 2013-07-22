require 'spec_helper'

describe Scheduler::Base do
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end
  describe "Respons to" do
    it { should respond_to(:delayed_at) }
    it { should respond_to(:ran_at) }
  end
  describe "Validations" do
    it { should validate_presence_of(:delayed_at) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:post_id) }
  end

end
