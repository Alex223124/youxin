require 'spec_helper'

describe ReceiptsController do
  include JsonParser

  before(:each) do
    @user = create :user
    login_user @user

    @admin = create :user
    @organization = create :organization
    @actions_youxin = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@admin, @actions_youxin)
    @organization.push_member(@user)
  end
  describe "GET index" do
    before(:each) do
      3.times do
        create :post, author: @admin, organization_ids: [@organization].map(&:id)
      end
    end
    it "returns http success" do
      get 'index'
      response.should be_success
    end
    it "should return the array of receipts of current user" do
      get 'index'
      json_response.should have_key('receipts')
      json_response['receipts'].size.should == 3
    end
    it "should return unread receipts of current" do
      2.times { @user.receipts.unread.first.read! }
      get 'index', status: :unread
      json_response.should have_key('receipts')
      json_response['receipts'].size.should == 1
    end
    it "should return read receipts of current user" do
      2.times { @user.receipts.unread.first.read! }
      get 'index', status: :read
      json_response.should have_key('receipts')
      json_response['receipts'].size.should == 2
    end
  end
  describe "PUT read" do
    before(:each) do
      3.times do
        create :post, author: @admin, organization_ids: [@organization].map(&:id)
      end
      @user_another = create :user
      @organization_another = create :organization
      @organization_another.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_another.push_member(@user_another)

      @post_another = create :post, author: @admin, organization_ids: [@organization_another].map(&:id)
    end
    it "should mark the receipt as read" do
      receipt = @user.receipts.first
      expect do
        put :read, id: receipt.id
        receipt.reload
      end.to change { receipt.read_at }
      response.status.should == 204
    end
    it "should return 404 if receipt doesnt exist" do
      put :read, id: :not_exists
      response.status.should == 404
    end
    it "should return 404 if receipt doesnt exist" do
      receipt = @post_another.receipts.where(user_id: @user_another.id).first
      put :read, id: receipt.id
      response.status.should == 404
    end
  end
  describe "PUT /favorite" do
    before(:each) do
      create :post, author: @admin, organization_ids: [@organization].map(&:id)

      @user_another = create :user
      @organization_another = create :organization
      @organization_another.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_another.push_member(@user_another)

      @post_another = create :post, author: @admin, organization_ids: [@organization_another].map(&:id)
    end
    it "should return 201" do
      receipt = @user.receipts.first
      post :favorite, id: receipt.id
      response.status.should == 201
    end
    it "should favorite the receipt" do
      receipt = @user.receipts.first
      post :favorite, id: receipt.id
      receipt.favorites.count.should == 1
      @user.favorites.receipts.count.should == 1
    end
    it "should return 404 if receipt doesnt exist" do
      post :favorite, id: :not_exists
      response.status.should == 404
    end
    it "should return 404 if receipt doesnt exist" do
      receipt = @post_another.receipts.where(user_id: @user_another.id).first
      post :favorite, id: receipt.id
      response.status.should == 404
    end
  end
  describe "DELETE /favorite" do
    before(:each) do
      create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @receipt = @user.receipts.first
      favorite = @receipt.favorites.first_or_create user_id: @user.id
    end
    it "should return 204" do
      delete :unfavorite, id: @receipt.id
      response.status.should == 204
    end
    it "should unfavorite the receipt" do
      expect do
        delete :unfavorite, id: @receipt.id
      end.to change { @user.favorites.receipts.count }.by(-1)
    end
  end
  describe 'GET mobile_show' do
    before(:each) do
      create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @receipt = @user.receipts.first
    end
    it 'should return 200' do
      get :mobile_show, short_key: @receipt.short_key
      response.status.should == 200
    end
    it 'should read the receipt' do
      get :mobile_show, short_key: @receipt.short_key
      @receipt.reload
      @receipt.read.should == true
    end
    it 'should return 404' do
      get :mobile_show, short_key: 'not_exist'
      response.status.should == 404
    end
  end
  describe 'POST mobile_create_collection' do
    before(:each) do
      @form_json = {
        title: 'form-first',
        inputs: [
          # TextField
          {
            _type: 'Field::TextField',
            label: 'text_field',
            help_text: 'text field help text',
            required: true,
            default_value: 'text field default value'
          },
          # TextArea
          {
            _type: 'Field::TextArea',
            label: 'text_area',
            help_text: 'text area help text',
            required: true,
            default_value: 'text area default value'
          },
          # RadioButton
          {
            _type: 'Field::RadioButton',
            label: 'radio_button',
            help_text: 'radio button help text',
            required: true,
            options: [
              {
                _type: 'Field::Option',
                default_selected: true,
                value: 'radio_button option one'
              },
              {
                _type: 'Field::Option',
                default_selected: false,
                value: 'radio_button option two'
              },
              {
                _type: 'Field::Option',
                default_selected: false,
                value: 'radio_button option three'
              }
            ]
          },
          # CheckBox
          {
            _type: 'Field::CheckBox',
            label: 'check_box',
            help_text: 'check box help text',
            required: true,
            options: [
              {
                _type: 'Field::Option',
                default_selected: true,
                value: 'check_box option one'
              },
              {
                _type: 'Field::Option',
                default_selected: true,
                value: 'check_box option two'
              },
              {
                _type: 'Field::Option',
                default_selected: false,
                value: 'check_box option three'
              }
            ]
          },
          # NumberField
          {
            _type: 'Field::NumberField',
            label: 'number_field',
            help_text: 'number field help text',
            required: true,
            default_value: '123'
          }
        ]
      }
      @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
      @form = @post.forms.create(Form.clean_attributes_with_inputs(@form_json).merge({ user_id: @admin.id }))
      @entities_json = {
        field_1: 'text_field test',
        field_2: 'text_area test',
        field_3: @form.radio_buttons.first.options.first.id,
        field_4: [@form.check_boxes.first.options[0], @form.check_boxes.first.options[1]].map(&:id),
        field_5: 123
      }
      @receipt = @user.receipts.first
    end
    it 'should create collection' do
      expect do
        post :mobile_collection_create, short_key: @receipt.short_key, collection: @entities_json
      end.to change{ @form.collections.count }.by(1)
    end
    it 'should be forms_filled' do
      post :mobile_collection_create, short_key: @receipt.short_key, collection: @entities_json
      @receipt.reload
      @receipt.forms_filled.should == true
    end
  end
end

