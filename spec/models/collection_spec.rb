require 'spec_helper'

describe Collection do
  describe "Association" do
    it { should belong_to(:form) }
    it { should belong_to(:user) }
    it { should embed_many(:entities) }
  end
  describe "Respond to" do
    # it { should respond_to(:field) }
    # it { should respond_to(:value) }
  end

  describe ".clean_attributes_with_entities" do
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
            default_value: '123'
          }
        ]
      }
      @author = create :user
      @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
      @user = create :user
      @entities = {
        field_1: 'text_field test',
        field_2: 'text_area test',
        field_3: @form.radio_buttons.first.options.first.id,
        field_4: [@form.check_boxes.first.options[0], @form.check_boxes.first.options[1]].map(&:id),
        field_5: 123
      }
    end

    it "successed" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should be_valid
    end

    it "fails when required" do
      @entities.delete(:field_2)
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should_not be_valid
      collection.should have(1).error_on(:entities)
    end

    it "should successed when not required" do
      @entities.delete(:field_5)
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should be_valid
    end

    it "should fail when bad radio_button option" do
      @entities[:field_3] = 123
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should_not be_valid
      collection.should have(1).error_on(:entities)
    end

    it "should fail when bad check_box options" do
      @entities[:field_4] = [123]
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should_not be_valid
      collection.should have(1).error_on(:entities)
    end
    it "should fail when bad check_box options type" do
      @entities[:field_4] = 123
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should_not be_valid
      collection.should have(1).error_on(:entities)
    end

    it "should fail when bad number_field type" do
      @entities[:field_5] = 'achd'
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      collection.should_not be_valid
      collection.should have(1).error_on(:entities)
    end

    context "text_field" do
      before(:each) do
        @form_json_required = {
          title: 'form-first',
          inputs: [
            # TextField
            {
              _type: 'Field::TextField',
              label: 'text_field',
              help_text: 'text field help text',
              required: true,
              default_value: 'text field default value'
            }
          ]
        }
        @form_json_not_required = {
          title: 'form-first',
          inputs: [
            # TextField
            {
              _type: 'Field::TextField',
              label: 'text_field',
              help_text: 'text field help text',
              default_value: 'text field default value'
            }
          ]
        }
        @author = create :user
        @user = create :user
        @entities = {
          field_1: 'text_field test'
        }
      end
      it "successed" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when not required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "fails when required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
    end
    context "text_area" do
      before(:each) do
        @form_json_required = {
          title: 'form-first',
          inputs: [
            # TextArea
            {
              _type: 'Field::TextArea',
              label: 'text_area',
              help_text: 'text area help text',
              required: true,
              default_value: 'text area default value'
            }
          ]
        }
        @form_json_not_required = {
          title: 'form-first',
          inputs: [
            # TextArea
            {
              _type: 'Field::TextArea',
              label: 'text_area',
              help_text: 'text area help text',
              default_value: 'text area default value'
            }
          ]
        }
        @author = create :user
        @user = create :user
        @entities = {
          field_1: 'text_area test'
        }
      end
      it "successed" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when not required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "fails when required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
    end
    context "radio_button" do
      before(:each) do
        @form_json_required = {
          title: 'form-first',
          inputs: [
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
            }
          ]
        }
        @form_json_not_required = {
          title: 'form-first',
          inputs: [
            # RadioButton
            {
              _type: 'Field::RadioButton',
              label: 'radio_button',
              help_text: 'radio button help text',
              required: false,
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
            }
          ]
        }
        @author = create :user
        @user = create :user
        @entities = {
          field_1: ''
        }
      end
      it "successed" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        @entities[:field_1] = @form.radio_buttons.first.options.first.id
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when not required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "fails when required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
      it "fails when field is an Array" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        @entities[:field_1] = @form.radio_buttons.first.options.map(&:id)
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
    end
    context "check_box" do
      before(:each) do
        @form_json_required = {
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
          ]
        }
        @form_json_not_required = {
          title: 'form-first',
          inputs: [
            # CheckBox
            {
              _type: 'Field::CheckBox',
              label: 'check_box',
              help_text: 'check box help text',
              required: false,
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
          ]
        }
        @author = create :user
        @user = create :user
        @entities = {
          field_1: ''
        }
      end
      it "successed" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        @entities[:field_1] = [@form.check_boxes.first.options.first.id]
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when not required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "fails when required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
      it "fails when field is not an Array" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        @entities[:field_1] = @form.check_boxes.first.options.first.id
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
      it "successed when field is an Array" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        options = @form.check_boxes.first.options
        @entities[:field_1] = [options[0], options[1]].map(&:id)
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
    end
    context "number_field" do
      before(:each) do
        @form_json_required = {
          title: 'form-first',
          inputs: [
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
        @form_json_not_required = {
          title: 'form-first',
          inputs: [
            # NumberField
            {
              _type: 'Field::NumberField',
              label: 'number_field',
              help_text: 'number field help text',
              default_value: '123'
            }
          ]
        }
        @author = create :user
        @user = create :user
        @entities = {
          field_1: '123'
        }
      end
      it "successed" do
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when not required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when it is float" do
        @entities[:field_1] = 123.1234
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when it is negative number" do
        @entities[:field_1] = -123.1234
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "successed when it is positive number" do
        @entities[:field_1] = +123.1234
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_not_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should be_valid
      end
      it "fails when required" do
        @entities.delete(:field_1)
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
      it "fails when invalid" do
        @entities[:field_1] = 'abcd'
        @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json_required))
        collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
        collection.should_not be_valid
        collection.should have(1).error_on(:entities)
      end
    end
  end

  describe "#update" do
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
            default_value: '123'
          }
        ]
      }
      @author = create :user
      @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json))
      @user = create :user
      @entities = {
        field_1: 'text_field test',
        field_2: 'text_area test',
        field_3: @form.radio_buttons.first.options.first.id,
        field_4: [@form.check_boxes.first.options[0], @form.check_boxes.first.options[1]].map(&:id),
        field_5: 123
      }
    end

    it "successed modify text_field" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      @entities[:field_1] = 'text_field modify'
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_1).first.value.should == 'text_field modify'
    end
    it "fails modify text_field" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      field_1 = @entities[:field_1]
      @entities[:field_1] = ''
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_1).first.value.should == field_1
    end
    it "successed modify text_area" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      @entities[:field_2] = 'text_area modify'
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_2).first.value.should == 'text_area modify'
    end
    it "fails modify text_area" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      field_2 = @entities[:field_2]
      @entities[:field_2] = ''
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_2).first.value.should == field_2
    end
    it "successed modify radio_button" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      @entities[:field_3] = @form.radio_buttons.first.options.last.id
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_3).first.value.should == @form.radio_buttons.first.options.last.id
    end
    it "fails modify radio_button" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      field_3 = @entities[:field_3]
      @entities[:field_3] = '12314'
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_3).first.value.should == field_3
    end
    it "successed modify check_box" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      options = @form.check_boxes.first.options
      @entities[:field_4] = [options.first, options.last].map(&:id)
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_4).first.value.should == [options.first, options.last].map(&:id)
    end
    it "fails modify check_box" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      field_4 = @entities[:field_4]
      @entities[:field_4] = [1, 2]
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_4).first.value.should == field_4
    end
    it "successed modify number_field" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      @entities[:field_5] = 777
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_5).first.value.should == 777
    end
    it "fails modify number_field" do
      collection = @form.collections.create(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: @user.id }))
      @entities[:field_5] = 'a'
      collection.update_attributes(Collection.clean_attributes_for_update(@entities, collection))
      collection.reload
      collection.entities.where(key: :field_5).first.value.should == 123
    end

  end
end
