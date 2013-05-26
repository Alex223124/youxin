require 'spec_helper'

describe Youxin::API, 'posts' do
  include ApiHelpers

  before(:each) do
    @user = create :user
    @admin = create :user
    @organization = create :organization
    @organization_another = create :organization

    @organization.add_member(@user)
    @actions = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@admin, @actions)
    @organization.authorize_cover_offspring(@user, @actions)

    @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
    @file = Rack::Test::UploadedFile.new(@file_path)
    @image_path = Rails.root.join("spec/factories/data/attachment_image.png")
    @image = Rack::Test::UploadedFile.new(@image_path)
  end

  describe "POST /post" do
    it "should create post" do
      attrs = attributes_for(:post).merge!({
        organization_ids: [@organization].map(&:id)
      })
      expect {
        post api('/posts', @admin), attrs
      }.to change { Post.count }.by(1)
    end

    context "attachments" do
      it "should append attachments to post" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id)
        })
        attachment_ids = []
        post api('/attachments', @admin), { file: @file }
        attachment_ids << json_response['id']
        post api('/attachments', @admin), { file: @image }
        attachment_ids << json_response['id']

        attrs = attrs.merge({
          attachment_ids: attachment_ids
        })
        post api('/posts', @admin), attrs
        json_response['attachments'].should be_kind_of Array
        json_response['attachments'].first['id'].should == attachment_ids.first
        json_response['attachments'].last['id'].should == attachment_ids.last
      end

      it "should not append attachments if attachments does not belong to user" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id)
        })
        attachment_ids = []
        post api('/attachments', @user), { file: @file }
        attachment_ids << json_response['id']
        post api('/attachments', @admin), { file: @image }
        attachment_ids << json_response['id']

        attrs = attrs.merge({
          attachment_ids: attachment_ids
        })
        post api('/posts', @admin), attrs
        response.status.should == 400
        json_response['attachment_ids'].should_not be_nil
      end
    end
    context "when unauthorized organization" do
      it "should not create" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization, @organization_another].map(&:id)
        })
        post api('/posts', @admin), attrs
        response.status.should == 403
      end
    end
  end

  describe "GET /posts/:id/forms" do
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
            required: true,
            default_value: '123'
          }
        ]
      }
      @author = create :author
      @post = create :post, author: @author, organization_ids: [@organization].map(&:id)
      @form = @author.forms.create(Form.clean_attributes_with_inputs(@form_json).merge({ post_id: @post.id }))
    end

    it "should get forms" do
      get api("/posts/#{@post.id}/forms", @user)
      response.status.should == 200
      json_response.size.should == 1
    end

    it "should not found post" do
      get api("/posts/not_exist/forms", @user)
      response.status.should == 404      
    end

  end
end