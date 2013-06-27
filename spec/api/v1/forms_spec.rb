require 'spec_helper'

describe Youxin::API, 'forms' do
  include ApiHelpers
  before(:each) do
    @user = create :user
    @user_another = create :user
    @author = create :author
    @organization = create :organization

    @organization.add_member(@user)
    @actions = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@author, @actions)

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
              selected: true,
              value: 'radio_button option one'
            },
            {
              _type: 'Field::Option',
              selected: false,
              value: 'radio_button option two'
            },
            {
              _type: 'Field::Option',
              selected: false,
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
              selected: true,
              value: 'check_box option one'
            },
            {
              _type: 'Field::Option',
              selected: true,
              value: 'check_box option two'
            },
            {
              _type: 'Field::Option',
              selected: false,
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
    @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
    @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json).merge({ post_id: @post.id }))
  end
  describe "GET /forms/:id" do
    it "should get the form" do
      get api("/forms/#{@form.id}", @user)
      response.status.should == 200
      json_response['inputs'].size.should == 5
      json_response['id'].should == @form.id.as_json
      json_response['title'].should == @form.title.as_json
    end

    it "should not found form" do
      get api("/forms/not_exist", @user)
      response.status.should == 404      
    end

    it "should not authorized" do
      get api("/forms/#{@form.id}", @user_another)
      response.status.should == 403
    end
  end

end
