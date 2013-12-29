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
    it { should respond_to(:device) }
    it { should respond_to(:version_code) }
    it { should respond_to(:version_name) }
  end

  describe 'Attributes' do
    before(:each) do
      @valid_attrs = attributes_for(:feedback)
    end
    context '#body' do
      it 'should raise error on body' do
        @valid_attrs.delete(:body)
        feedback = Feedback.create @valid_attrs
        feedback.should have(1).error_on(:body)
      end
    end
  end

end
