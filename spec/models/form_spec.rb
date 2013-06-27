require 'spec_helper'

describe Form do
  let(:form) { build :form }
  subject { form }
  describe "Association" do
    it { should belong_to(:author) }
    it { should belong_to(:post) }
    it { should have_many(:collections) }
    it { should have_many(:inputs) }
    it { should have_many(:text_fields) }
    it { should have_many(:text_areas) }
    it { should have_many(:radio_buttons) }
    it { should have_many(:check_boxes) }
    it { should have_many(:number_fields) }
    it { should belong_to(:post) }
  end

  describe "Respond to" do
    it { should respond_to(:title) }
  end

  describe ".clean_attributes_with_inputs" do
    it "should succeed" do
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
      @author = create :author
      form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
      form.inputs.count.should == 5
      form.inputs[0].should be_a_kind_of(Field::TextField)
      form.inputs[1].should be_a_kind_of(Field::TextArea)
      form.inputs[2].should be_a_kind_of(Field::RadioButton)
      form.inputs[3].should be_a_kind_of(Field::CheckBox)
      form.inputs[4].should be_a_kind_of(Field::NumberField)
    end

    context "text_field" do
      before(:each) do
        @form_json = {
          title: 'form-first',
          inputs: [
            # TextField
            {
              _type: 'Field::TextField',
              label: 'text_field_1',
              help_text: 'text field help text',
              required: true,
              default_value: 'text field 1 default value'
            },
            # TextField
            {
              _type: 'Field::TextField',
              label: 'text_field_2',
              help_text: 'text field help text',
              required: true,
              default_value: 'text field 2 default value'
            }
          ]
        }
      end
      it "when multi" do
        @author = create :author
        form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
        form.inputs.count.should == 2
        form.inputs.first.should be_a_kind_of(Field::TextField)
        form.inputs.first.should be_a_kind_of(Field::TextField)
      end
    end

    context "text_area" do
      before(:each) do
        @form_json = {
          title: 'form-first',
          inputs: [
            # TextArea
            {
              _type: 'Field::TextArea',
              label: 'text_area_1',
              help_text: 'text area 1 help text',
              required: true,
              default_value: 'text area 1 default value'
            },
            # TextArea
            {
              _type: 'Field::TextArea',
              label: 'text_area_2',
              help_text: 'text area 2 help text',
              required: true,
              default_value: 'text area 2 default value'
            }
          ]
        }
      end
      it "when multi" do
        @author = create :author
        form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
        form.inputs.count.should == 2
        form.inputs.first.should be_a_kind_of(Field::TextArea)
        form.inputs.first.should be_a_kind_of(Field::TextArea)
      end
    end

    context "radio_button" do
      before(:each) do
        @form_json = {
          title: 'form-first',
          inputs: [
            # RadioButton
            {
              _type: 'Field::RadioButton',
              label: 'radio_button_1',
              help_text: 'radio button help text',
              required: true,
              options: [
                {
                  _type: 'Field::Option',
                  default_selected: true,
                  value: 'radio_button_1 option one'
                },
                {
                  _type: 'Field::Option',
                  default_selected: false,
                  value: 'radio_button_1 option two'
                },
                {
                  _type: 'Field::Option',
                  default_selected: false,
                  value: 'radio_button_1 option three'
                }
              ]
            },
            # RadioButton
            {
              _type: 'Field::RadioButton',
              label: 'radio_button_2',
              help_text: 'radio button help text',
              required: true,
              options: [
                {
                  _type: 'Field::Option',
                  default_selected: true,
                  value: 'radio_button_2 option one'
                },
                {
                  _type: 'Field::Option',
                  default_selected: false,
                  value: 'radio_button_2 option two'
                },
                {
                  _type: 'Field::Option',
                  default_selected: false,
                  value: 'radio_button_2 option three'
                }
              ]
            }
          ]
        }
      end
      it "when multi" do
        @author = create :author
        form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
        form.inputs.count.should == 2
        form.inputs[0].should be_a_kind_of(Field::RadioButton)
        form.inputs[1].should be_a_kind_of(Field::RadioButton)
      end
      it "when multi options selected" do
        multi_selected = {
          _type: 'Field::RadioButton',
          label: 'radio_button_3',
          help_text: 'radio button help text',
          required: true,
          options: [
            {
              _type: 'Field::Option',
              default_selected: true,
              value: 'radio_button_3 option one'
            },
            {
              _type: 'Field::Option',
              default_selected: true,
              value: 'radio_button_3 option two'
            },
            {
              _type: 'Field::Option',
              default_selected: false,
              value: 'radio_button_3 option three'
            }
          ]
        }
        @form_json[:inputs] << multi_selected
        @author = create :author
        form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
        form.should have(1).error_on(:radio_buttons)
      end
    end

    context "description" do
      before(:each) do
        @form_json = {
          title: 'form-first',
          inputs: [
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
            }
          ]
        }
      end
      it "when multi" do
        @author = create :author
        form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
        form.inputs.count.should == 2
        form.inputs[0].should be_a_kind_of(Field::CheckBox)
        form.inputs[1].should be_a_kind_of(Field::CheckBox)
      end
      it "when multi_selected" do
        multi_selected = {
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
        }
        @form_json[:inputs] << multi_selected

      end
    end

  end
end
