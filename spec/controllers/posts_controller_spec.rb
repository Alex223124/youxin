require 'spec_helper'

describe PostsController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:current_user) { create :user, namespace: namespace }
  let(:admin) { create :user, namespace: namespace }
  before(:each) do
    @parent = create :organization, namespace: namespace
    @current = create :organization, parent: @parent, namespace: namespace
    @parent.add_member(current_user)
    actions_youxin = Action.options_array_for(:youxin)
    @parent.authorize_cover_offspring(admin, actions_youxin)
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

  describe "GET unread_receipts" do
    before(:each) do
      @post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
      login_user admin
    end
    it "should return the array of unread receipts" do
      get :unread_receipts, id: @post.id
      json_response['unread_receipts'].should be_a_kind_of(Array)
    end
    it "should return the unread receipts" do
      get :unread_receipts, id: @post.id
      json_response['unread_receipts'].count.should == 1
    end
    it "should return 403" do
      login_user current_user
      get :unread_receipts, id: @post.id
      response.status.should == 403
    end
    it "should return 404" do
      get :unread_receipts, id: 'not_exists'
      response.status.should == 404
    end
  end
  describe "GET forms" do
    before(:each) do
      @post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
      login_user current_user
      @form = @post.forms.create(Form.clean_attributes_with_inputs(@form_json).merge({ user_id: admin.id }))
    end
    it "should return the array of forms" do
      get :forms, id: @post.id
      json_response['forms'].should be_a_kind_of(Array)
    end
    it "should return the forms of the post" do
      get :forms, id: @post.id
      json_response['forms'].size.should == 1
    end
    it "should return 403" do
      another_uesr = create :user, namespace: namespace
      login_user another_uesr
      get :forms, id: @post.id
      response.status.should == 403
    end
  end
  describe "POST create" do
    before(:each) do
      login_user admin
      @valid_attrs = {
        title: 'title',
        body_html: '<div>body_html</div>',
        organization_ids: [@parent, @current].map(&:id)
      }
    end
    it "should create a new post" do
      expect do
        post :create, post: @valid_attrs
      end.to change { Post.count }.by(1)
    end
    it "should return 422 when no body_html" do
      @valid_attrs.delete(:body_html)
      post :create, post: @valid_attrs
      response.status.should == 422
    end
    it "should return 403" do
      login_user current_user
      post :create, post: @valid_attrs
      response.status.should == 403
    end
    context "organization_ids" do
      it "should return 403" do
        another_organization = create :organization, namespace: namespace
        attrs = @valid_attrs.merge({ organization_ids: [another_organization].map(&:id) })
        post :create, post: attrs
        response.status.should == 403
      end
    end
    context "attachments" do
      before(:each) do
        file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
        file = Rack::Test::UploadedFile.new(file_path, 'text/plain')
        @attachment_file = admin.file_attachments.create(storage: file)
      end
      it "should succeed" do
        attrs = @valid_attrs.merge({
          attachment_ids: [@attachment_file].map(&:id)
        })
        post :create, post: attrs
        response.status.should == 201
      end
      it "should update the post_id of attachments" do
        attrs = @valid_attrs.merge({
          attachment_ids: [@attachment_file].map(&:id)
        })
        expect do
          post :create, post: attrs
          @attachment_file.reload
        end.to change { @attachment_file.post_id }
      end
      it "should return 404" do
        old_post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
        @attachment_file.update_attributes(post_id: old_post.id)
        attrs = @valid_attrs.merge({
          attachment_ids: [@attachment_file].map(&:id)
        })
        post :create, post: attrs
        response.status.should == 404
      end
    end
    context "forms" do
      before(:each) do
        @form = admin.forms.create(Form.clean_attributes_with_inputs(@form_json))
      end
      it "should succeed" do
        attrs = @valid_attrs.merge({
          form_ids: [@form].map(&:id)
        })
        post :create, post: attrs
        response.status.should == 201
      end
      it "should update the post_id of forms" do
        attrs = @valid_attrs.merge({
          form_ids: [@form].map(&:id)
        })
        expect do
          post :create, post: attrs
          @form.reload
        end.to change { @form.post_id }
      end
      it "should return 404" do
        old_post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
        @form.update_attributes(post_id: old_post.id)
        attrs = @valid_attrs.merge({
          form_ids: [@form].map(&:id)
        })
        post :create, post: attrs
        response.status.should == 404
      end
    end
    context "delayed_sms_notification" do
      it "should succeed" do
        timestamp = Time.now.to_i
        attrs = @valid_attrs.merge({ delayed_sms_at: timestamp })
        expect do
          post :create, post: attrs
        end.to change { Scheduler::Sms.count }.by(1)
      end
    end
  end
  describe "POST run_sms_notifications_now" do
    before(:each) do
      login_user admin
      @post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
    end
    it "should return 204" do
      post :run_sms_notifications_now, id: @post.id
      response.status.should == 204
    end
    it "should create a sms_notification for the post" do
      expect do
        post :run_sms_notifications_now, id: @post.id
      end.to change { @post.sms_schedulers.count }.by(1)
    end
    it "should return 403" do
      login_user current_user
      post :run_sms_notifications_now, id: @post.id
      response.status.should == 403
    end
  end
  describe "GET last_sms_scheduler" do
    before(:each) do
      login_user admin
      @post = create :post, author: admin, organization_ids: [@parent, @current].map(&:id)
      @post.sms_schedulers.create delayed_at: 1.days.from_now
    end
    it "should return last sms_scheduler" do
      get :last_sms_scheduler, id: @post.id
      json_response['sms_scheduler'].should_not be_blank
    end
    it "should return 403" do
      login_user current_user
      get :last_sms_scheduler, id: @post.id
      response.status.should == 403
    end
  end
end