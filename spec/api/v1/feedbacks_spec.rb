require 'spec_helper'

describe Youxin::API, 'help' do
  include ApiHelpers

  let(:namespace) { create :namespace }
  let(:user) { create :user, namespace: namespace }

  describe "POST /Feedbacks" do
    before(:each) do
      @valid_attrs = attributes_for(:feedback)
    end
    it 'should return 401' do
      post api('/feedbacks'), @valid_attrs
      response.status.should == 401
    end
    it 'should return 201' do
      post api('/feedbacks', user), @valid_attrs
      response.status.should == 201
    end
    it "should create a new feedback" do
      expect {
        post api('/feedbacks', user), @valid_attrs
      }.to change { Feedback.count }.by(1)
    end
    it 'should return 422' do
      @valid_attrs.delete(:body)
      post api('/feedbacks', user), @valid_attrs
      response.status.should == 400
    end
  end
end
