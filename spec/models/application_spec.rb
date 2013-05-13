require 'spec_helper'

describe Application do
  let(:application) { build :application }
  subject { application }

  describe "Association" do
    it { should belong_to(:applicant) }
    it { should belong_to(:organization) }
    it { should belong_to(:operator) }
  end
end
