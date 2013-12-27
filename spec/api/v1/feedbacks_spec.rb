require 'spec_helper'

describe Youxin::API, 'help' do
  include ApiHelpers

  let(:namespace) { create :namespace }
  let(:user) { create :user, namespace: namespace }

  describe "POST /Feedbacks" do
    it 'should return 401' do
      post api('/feedbacks')
      response.status.should == 401
    end
    it 'should return 201' do
      post api('/feedbacks', user)
      response.status.should == 201
    end
    it "should create a new feedback" do
      expect {
        post api('/feedbacks', user)
      }.to change { Feedback.count }.by(1)
    end
  end
end
