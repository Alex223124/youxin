require 'spec_helper'

describe Youxin::API, 'password' do
  include ApiHelpers

  let(:user) { create :user }

  before(:each) do
    stub_request(:any, 'http://api.smsbao.com/sms').to_return(body: '0')
  end

  describe "POST /password" do
    it 'should return 400' do
      post api('/password'), unknow: 'unknow'
      response.status.should == 400
    end

    context 'reset by sms' do
      it 'should generate reset_sms_token' do
        expect do
          post api('/password'), phone: user.phone
          user.reload
        end.to change { user.reset_sms_token }
      end
      it 'should return 201' do
        post api('/password'), phone: user.phone
        response.status.should == 201
        json_response.should == {
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at,
          avatar: user.avatar.url
        }.as_json
      end
      it 'should railse error when phone not found' do
        post api('/password'), phone: 'not_exist'
        response.status.should == 400
        json_response['phone'].should_not be_nil
      end
    end

    context 'reset by email' do
      it 'should generate reset_password_token' do
        expect do
          post api('/password'), email: user.email
          user.reload
        end.to change { user.reset_password_token }
      end
      it 'should return 201' do
        post api('/password'), email: user.email
        response.status.should == 201
        json_response.should == {
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at,
          avatar: user.avatar.url
        }.as_json
      end
    end
  end

  describe 'GET /password/valid_token' do
    before(:each) do
      User.send_reset_sms(phone: user.phone)
      user.reload
    end
    it 'should return 200 if valid' do
      get api('/password/valid_token'), reset_sms_token: user.reset_sms_token, phone: user.phone
      response.status.should == 200
      json_response.should == {
        id: user.id,
        name: user.name,
        email: user.email,
        created_at: user.created_at,
        avatar: user.avatar.url
      }.as_json
    end
    it 'should return 400 if blank' do
      get api('/password/valid_token'), phone: user.phone
      response.status.should == 400
    end
    it 'should return 400 if not exist' do
      get api('/password/valid_token'), reset_sms_token: 'not_exist', phone: user.phone
      response.status.should == 400
      json_response['reset_sms_token'].should_not be_blank
    end
    it 'should return 400 if expired' do
      user.reset_sms_sent_at = 1.day.ago
      user.save
      get api('/password/valid_token'), reset_sms_token: user.reset_sms_token, phone: user.phone
      response.status.should == 400
      json_response['reset_sms_token'].should_not be_blank
    end
  end

  describe 'PUT /password' do
    before(:each) do
      User.send_reset_sms(phone: user.phone)
      user.reload

      new_password = '12345678'
      @valid_attrs = {
        reset_sms_token: user.reset_sms_token,
        password: new_password,
        password_confirmation: new_password
      }
    end
    it 'should return 200 if valid' do
      put api('/password'), @valid_attrs
      response.status.should == 204
    end
    it 'should return 400 if password and password_confirmation not match' do
      attrs = @valid_attrs.merge({ password: 'new_password' })
      put api('/password'), attrs
      response.status.should == 400
      json_response['password'].should_not be_blank
    end
    it 'should return 400 if reset_sms_token expired' do
      user.reset_sms_sent_at = 1.days.ago
      user.save

      put api('/password'), @valid_attrs
      response.status.should == 400
      json_response['reset_sms_token'].should_not be_blank
    end
    it 'should return 4000 if reset_sms_token not exist' do
      attrs = @valid_attrs.merge({ reset_sms_token: 'not_exist' })

      put api('/password'), attrs
      response.status.should == 400
      json_response['reset_sms_token'].should_not be_blank
    end
  end

end
