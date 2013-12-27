require 'spec_helper'

describe Feedback do
  describe "Association" do
    it { should belong_to(:user) }
  end

  describe "Respond to" do
    it { should respond_to(:category) }
    it { should respond_to(:body) }
    it { should respond_to(:contact) }
    it { should respond_to(:user_id) }
    it { should respond_to(:devise) }
    it { should respond_to(:version_code) }
    it { should respond_to(:version_name) }
  end

end
