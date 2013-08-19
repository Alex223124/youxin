require 'spec_helper'

describe CollectionsController do
  include JsonParser

  let(:current_user) { create :user }
  let(:admin) { create :user }
  before(:each) do
    @parent = create :organization
    @current = create :organization, parent: @parent
    @parent.add_member(current_user)
    actions_organization = Action.options_array_for(:organization)
    @parent.authorize_cover_offspring(admin, actions_organization)

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
    post = create :post, author: admin, organization_ids: [@parent].map(&:id)
    @form = post.forms.create(Form.clean_attributes_with_inputs(@form_json).merge({ user_id: admin.id }))
    @entities_json = {
      field_1: 'text_field test',
      field_2: 'text_area test',
      field_3: @form.radio_buttons.first.options.first.id,
      field_4: [@form.check_boxes.first.options[0], @form.check_boxes.first.options[1]].map(&:id),
      field_5: 123
    }
  end

  describe "POST create" do
    before(:each) do
      login_user current_user
    end
    it "should create a new collection" do
      expect do
        post :create, form_id: @form.id, entities: @entities_json
      end.to change { @form.collections.count }.by(1)
    end
    it "should return 422 when bad attributes" do
      @entities_json.delete(:field_1)
      post :create, form_id: @form.id, entities: @entities_json
      response.status.should == 422
    end
    it "should return 403" do
      another_user = create :user
      login_user another_user
      post :create, form_id: @form.id, entities: @entities_json
      response.status.should == 403
    end
  end
  describe "GET index" do
    before(:each) do
      login_user admin
      @form.collections.create(Collection.clean_attributes_with_entities(@entities_json, @form).merge({ user_id: current_user.id }))
    end
    it "should return 200" do
      get :index, form_id: @form.id
      response.status.should == 200
    end
    it "should return collections" do
      get :index, form_id: @form.id
      json_response['collections'].should_not be_blank
      json_response['collections'].should be_a_kind_of(Array)
    end
    it "should return 403" do
      login_user current_user
      get :index, form_id: @form.id
      response.status.should == 403
    end
    it "should return 404" do
      get :index, form_id: 'not_exist'
      response.status.should == 404
    end
  end
  describe "GET show" do
    before(:each) do
      login_user current_user
    end
    it "should return 200" do
      @form.collections.create(Collection.clean_attributes_with_entities(@entities_json, @form).merge({ user_id: current_user.id }))
      get :show, form_id: @form.id
      response.status.should == 200
    end
    it "should return the collection writed by current_user" do
      @form.collections.create(Collection.clean_attributes_with_entities(@entities_json, @form).merge({ user_id: current_user.id }))
      get :show, form_id: @form.id
      json_response['collection'].should_not be_blank
    end
    it "should return 403" do
      another_user = create :user
      login_user another_user
      get :show, form_id: @form.id
      response.status.should == 403
    end
    it "should return 404" do
      get :show, form_id: @form.id
      response.status.should == 404
    end
  end
end
