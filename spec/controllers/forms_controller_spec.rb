require 'spec_helper'

describe FormsController do
  include JsonParser

  let(:current_user) { create :user }
  before(:each) do
    login_user current_user
    @parent = create :organization
    @current = create :organization, parent: @parent
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
  end

  describe "POST create" do
    before(:each) do
      admin = create :user
      login_user admin
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(admin, actions_organization)
    end
    it "should create a new form" do
      expect do
        post :create, form: @form_json
      end.to change { Form.count }.by(1)
    end
    it "should return 422 when no inputs" do
      @form_json.delete(:inputs)
      post :create, form: @form_json
      json_response
      response.status.should == 422
    end
    it "should return 422 when no title" do
      @form_json.delete(:title)
      post :create, form: @form_json
      json_response
      response.status.should == 422
    end
    it "should return 403" do
      login_user current_user
      post :create, form: @form_json
      response.status.should == 403
    end
  end
  describe "GET download" do
    before(:each) do
      admin = create :user
      login_user admin
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(admin, actions_organization)

      post = create :post, author: admin, organization_ids: [@parent].map(&:id)
      @form = post.forms.create(Form.clean_attributes_with_inputs(@form_json))
    end
    it "should return 200" do
      get :download, id: @form.id
      response.status.should == 200
    end
    it "should return the excel file" do
      get :download, id: @form.id
      response.header['Content-Disposition'].should == %(attachment; filename="#{@form.title}.xls")    end
    it "should return 404" do
      get :download, id: 'not_exists'
      response.status.should == 404
    end
    it "should return 403" do
      login_user current_user
      get :download, id: @form.id
      response.status.should == 403
    end
  end
end
