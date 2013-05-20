require 'spec_helper'

describe Attachment::Base do
  let(:attachment_base) { build :attachment_base }
  subject { attachment_base }
  describe "Association" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

end