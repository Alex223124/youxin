require 'spec_helper'

describe Notification::Mention do
  describe "Association" do
    it { should belong_to(:mentionable) }
  end
  describe "Validation" do
    it { should validate_presence_of(:mentionable_id) }
    it { should validate_presence_of(:mentionable_type) }
  end
end
