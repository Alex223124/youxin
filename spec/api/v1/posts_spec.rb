require 'spec_helper'

describe Youxin::API, 'posts' do
  include ApiHelpers

  let(:namespace) { create :namespace }

  before(:each) do
    @user = create :user, namespace: namespace
    @admin = create :user, namespace: namespace
    @organization = create :organization, namespace: namespace
    @organization_another = create :organization, namespace: namespace

    @organization.add_member(@user)
    @actions = Action.options_array_for(:youxin)
    @organization.authorize_cover_offspring(@admin, @actions)
    @organization.authorize_cover_offspring(@user, @actions)

    @file_path = Rails.root.join("spec/factories/data/attachment_file.txt")
    @file = Rack::Test::UploadedFile.new(@file_path, 'text/plain')
    @image_path = Rails.root.join("spec/factories/data/attachment_image.png")
    @image = Rack::Test::UploadedFile.new(@image_path, 'image/png')
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
    context 'title' do
      before(:each) do
        @attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id)
        })
        post api('/posts', @admin), @attrs
      end
      it 'should not create post if duplicated with last post' do
        expect {
          post api('/posts', @admin), @attrs
        }.to change { Post.count }.by(0)
      end
      it 'should return 422' do
        post api('/posts', @admin), @attrs
        response.status.should == 422
      end
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
        json_response['post']['attachments'].should be_kind_of Array
        json_response['post']['attachments'].first['id'].should == attachment_ids.last
        json_response['post']['attachments'].last['id'].should == attachment_ids.first
      end

      it "should not append attachments if attachments belongs to another post" do
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
        new_attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id),
          attachment_ids: attachment_ids
        })
        post api('/posts', @admin), attrs
        response.status.should == 201
        post api('/posts', @admin), new_attrs
        response.status.should == 400
        json_response['attachment_ids'].should_not be_nil
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
        response.status.should == 403
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
    context "delayed_sms_at" do
      it "should enqueue scheduler" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id),
          delayed_sms_at: Time.now.to_i
        })
        Resque.should_receive(:enqueue_at)
        post api('/posts', @admin), attrs
      end
      it "should not enqueue scheduler" do
        attrs = attributes_for(:post).merge!({
          organization_ids: [@organization].map(&:id)
        })
        Resque.should_not_receive(:enqueue_at)
        post api('/posts', @admin), attrs
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
      @author = create :author, namespace: namespace
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

  describe "GET /posts/:id" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @user_another = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization.authorize_cover_offspring(@admin, @actions_youxin)
      @organization.push_member(@user)
      @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
    end
    it "should return the single post" do
      get api("/posts/#{@post.id}", @user)
      response.status.should == 200
      json_response.should == {
        id: @post.id,
        title: @post.title,
        body: @post.body,
        body_html: @post.body_html,
        created_at: @post.created_at,
        author: {
          id: @post.author.id,
          email: @post.author.email,
          name: @post.author.name,
          created_at: @post.author.created_at,
          avatar: @post.author.avatar.url,
          phone: @post.author.phone
        },
        attachments: [],
        forms: []
      }.as_json
    end
    it "should return 404 if single post not exists" do
      get api('/posts/not_exist', @user)
      response.status.should == 404
    end
    it "should return 403 if user can not read the post" do
      get api("/posts/#{@post.id}", @user_another)
      response.status.should == 403
    end
    it "should return 200 status" do
      get api("/posts/#{@post.id}", @admin)
      response.status.should == 200
    end
  end

  describe "GET /posts/:id/receipt" do
    before(:each) do
      @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
    end
    it "should return 200" do
      get api("/posts/#{@post.id}/receipt", @user)
      response.status.should == 200
    end
    it "should return the receipt" do
      receipt = @user.receipts.where(post_id: @post.id).first
      get api("/posts/#{@post.id}/receipt", @user)
      json_response['id'].should == receipt.id.to_s
    end
    it "should return 404" do
      get api("/posts/not_exist/receipt", @user)
      response.status.should == 404
    end
  end

  describe "/posts/:id" do
    before(:each) do
      @admin = create :user, namespace: namespace
      @user = create :user, namespace: namespace
      @user_another = create :user, namespace: namespace
      @user_unauthoried = create :user, namespace: namespace
      @organization = create :organization, namespace: namespace
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization.authorize_cover_offspring(@admin, @actions_youxin)
      @organization.push_members([@user, @user_another])
      @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
    end
    context "GET /receipts" do
      it "should return the array of receipts" do
        get api("/posts/#{@post.id}/receipts", @admin)
        response.status.should == 200
        receipt_1 = @user.receipts.first
        receipt_2 = @user_another.receipts.first
        json_response.should == [
          {
            id: receipt_2.id,
            read: receipt_2.read,
            favorited: false,
            read_at: receipt_2.read_at,
            user: {
              id: receipt_2.user.id,
              email: receipt_2.user.email,
              name: receipt_2.user.name,
              created_at: receipt_2.user.created_at,
              avatar: receipt_2.user.avatar.url,
              phone: receipt_2.user.phone
            }
          },
          {
            id: receipt_1.id,
            read: receipt_1.read,
            favorited: false,
            read_at: receipt_1.read_at,
            user: {
              id: receipt_1.user.id,
              email: receipt_1.user.email,
              name: receipt_1.user.name,
              created_at: receipt_1.user.created_at,
              avatar: receipt_1.user.avatar.url,
              phone: receipt_1.user.phone
            }
          }
        ].as_json
      end
      it "should return 403 when user do not have authorization" do
        get api("/posts/#{@post.id}/receipts", @user)
        response.status.should == 403
      end
    end
    context "GET /unread_receipts" do
      it "should return the array of unread receipts" do
        receipt_1 = @user.receipts.first
        receipt_2 = @user_another.receipts.first
        receipt_1.read!
        get api("/posts/#{@post.id}/unread_receipts", @admin)
        response.status.should == 200
        json_response.should == [
          {
            id: receipt_2.id,
            read: receipt_2.read,
            favorited: false,
            read_at: receipt_2.read_at,
            user: {
              id: receipt_2.user.id,
              email: receipt_2.user.email,
              name: receipt_2.user.name,
              created_at: receipt_2.user.created_at,
              avatar: receipt_2.user.avatar.url,
              phone: receipt_2.user.phone
            }
          }
        ].as_json
      end
      it "should return 403 when user do not have authorization" do
        get api("/posts/#{@post.id}/unread_receipts", @user)
        response.status.should == 403
      end
    end
    context "GET /unread_receipts" do
      it "should return the array of unread receipts" do
        receipt_1 = @user.receipts.first
        receipt_2 = @user_another.receipts.first
        receipt_1.read!
        get api("/posts/#{@post.id}/read_receipts", @admin)
        response.status.should == 200
        json_response.should == [
          {
            id: receipt_1.id,
            read: receipt_1.read,
            favorited: false,
            read_at: receipt_1.read_at,
            user: {
              id: receipt_1.user.id,
              email: receipt_1.user.email,
              name: receipt_1.user.name,
              created_at: receipt_1.user.created_at,
              avatar: receipt_1.user.avatar.url,
              phone: receipt_1.user.phone
            }
          }
        ].as_json
      end
      it "should return 403 when user do not have authorization" do
        get api("/posts/#{@post.id}/read_receipts", @user)
        response.status.should == 403
      end
    end
    context "GET /comments" do
      before(:each) do
        @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
        @post.reload
      end
      it "should return the array of comments of the post when user received" do
        get api("/posts/#{@post.id}/comments", @user)
        response.status.should == 200
        json_response.should == [
          {
            id: @comment.id,
            body: @comment.body,
            created_at: @comment.created_at,
            user: {
              id: @comment.user.id,
              email: @comment.user.email,
              name: @comment.user.name,
              created_at: @comment.user.created_at,
              avatar: @comment.user.avatar.url
            }
          }
        ].as_json
      end
      it "should return the array of comments of the post when user issued" do
        get api("/posts/#{@post.id}/comments", @admin)
        response.status.should == 200
        json_response.should == [
          {
            id: @comment.id,
            body: @comment.body,
            created_at: @comment.created_at,
            user: {
              id: @comment.user.id,
              email: @comment.user.email,
              name: @comment.user.name,
              created_at: @comment.user.created_at,
              avatar: @comment.user.avatar.url
            }
          }
        ].as_json
      end
      it "should return 403 when user not authorize" do
        get api("/posts/#{@post.id}/comments", @user_unauthoried)
        response.status.should == 403
      end
    end
    context "POST /comments" do
      it "should create comment of the post when user received" do
        attrs = attributes_for(:comment)
        expect {
          post api("/posts/#{@post.id}/comments", @user), attrs
        }.to change { @post.comments.count }.by(1)
      end
      it "should create comment of the post when user issued" do
        attrs = attributes_for(:comment)
        expect {
          post api("/posts/#{@post.id}/comments", @admin), attrs
        }.to change { @post.comments.count }.by(1)
      end
      it "should read the receipt of the post when user received" do
        @receipt = @user.receipts.where(post_id: @post.id).first
        @receipt.read.should be_false
        attrs = attributes_for(:comment)
        post api("/posts/#{@post.id}/comments", @user), attrs
        @receipt.reload.read.should be_true
      end
      it "should return 403 when user not authorize" do
        attrs = attributes_for(:comment)
        post api("/posts/#{@post.id}/comments", @user_unauthoried), attrs
        response.status.should == 403
      end
      it "should return the comment" do
        attrs = attributes_for(:comment)
        post api("/posts/#{@post.id}/comments", @admin), attrs
        response.status.should == 201
        json_response['body'].should == attrs[:body]
        json_response['user'].should == {
          id: @admin.id,
          email: @admin.email,
          name: @admin.name,
          created_at: @admin.created_at,
          avatar: @admin.avatar.url
        }.as_json
      end
      it "should return 400 when bad attributes" do
        attrs = attributes_for(:comment)
        attrs.delete(:body)
        post api("/posts/#{@post.id}/comments", @admin), attrs
        response.status.should == 400
        json_response.to_s.should =~ /body/i
      end
    end
    context "POST /sms_notifications" do
      before do
        ResqueSpec.reset!
      end
      it "should return 204" do
      post api("/posts/#{@post.id}/sms_notifications", @admin)
      response.status.should == 204
      end
      it "should create a sms_scheduler" do
        expect do
          post api("/posts/#{@post.id}/sms_notifications", @admin)
        end.to change { @post.sms_schedulers.count }.by(1)
      end
      it "should update current sms_scheduler if it doesnt be executed" do
        sms_scheduler = @post.sms_schedulers.create delayed_at: 1.days.from_now
        post api("/posts/#{@post.id}/sms_notifications", @admin)
        SendSmsToUnreads.should have_scheduled(sms_scheduler.id)
      end
      it "should return 403 if user cannt manage this post" do
        post api("/posts/#{@post.id}/sms_notifications", @user)
        response.status.should == 403
      end
    end
    context "GET /sms_scheduler" do
      before do
        ResqueSpec.reset!
      end
      it "should return nothing" do
        get api("/posts/#{@post.id}/sms_scheduler", @admin)
        response.status.should == 200
      end
      it "should return the last sms_scheduler" do
        sms_scheduler = @post.sms_schedulers.create delayed_at: 1.days.from_now
        get api("/posts/#{@post.id}/sms_scheduler", @admin)
        json_response.should == {
          delayed_at: sms_scheduler.delayed_at,
          ran_at: sms_scheduler.ran_at
        }.as_json
      end
      it "should return the last ran sms_scheduler" do
        timestamp = 1.days.from_now
        sms_scheduler = @post.sms_schedulers.create delayed_at: timestamp
        sms_scheduler.ran_at = Time.now
        sms_scheduler.save
        get api("/posts/#{@post.id}/sms_scheduler", @admin)
        json_response['ran_at'].should_not be_nil
      end
      it "should return 403" do
        get api("/posts/#{@post.id}/sms_scheduler", @user)
        response.status.should == 403
      end
    end
    context "POST /call_notifications" do
      before do
        ResqueSpec.reset!
      end
      it "should return 204" do
      post api("/posts/#{@post.id}/call_notifications", @admin)
      response.status.should == 204
      end
      it "should create a call_scheduler" do
        expect do
          post api("/posts/#{@post.id}/call_notifications", @admin)
        end.to change { @post.call_schedulers.count }.by(1)
      end
      it "should update current call_scheduler if it doesnt be executed" do
        call_scheduler = @post.call_schedulers.create delayed_at: 1.days.from_now
        post api("/posts/#{@post.id}/call_notifications", @admin)
        MakeCallsToUnreadsJob.should have_scheduled(call_scheduler.id)
      end
      it "should return 403 if user cannt manage this post" do
        post api("/posts/#{@post.id}/call_notifications", @user)
        response.status.should == 403
      end
    end
    context "GET /call_scheduler" do
      before do
        ResqueSpec.reset!
      end
      it "should return nothing" do
        get api("/posts/#{@post.id}/call_scheduler", @admin)
        response.status.should == 200
      end
      it "should return the last call_scheduler" do
        call_scheduler = @post.call_schedulers.create delayed_at: 1.days.from_now
        get api("/posts/#{@post.id}/call_scheduler", @admin)
        json_response.should == {
          delayed_at: call_scheduler.delayed_at,
          ran_at: call_scheduler.ran_at
        }.as_json
      end
      it "should return the last ran call_scheduler" do
        timestamp = 1.days.from_now
        call_scheduler = @post.call_schedulers.create delayed_at: timestamp
        call_scheduler.ran_at = Time.now
        call_scheduler.save
        get api("/posts/#{@post.id}/call_scheduler", @admin)
        json_response['ran_at'].should_not be_nil
      end
      it "should return 403" do
        get api("/posts/#{@post.id}/call_scheduler", @user)
        response.status.should == 403
      end
    end
  end

end
