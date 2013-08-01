class PostsController < ApplicationController
  before_filter :ensure_post, only: [:unread_receipts, :get_comments, :create_comments, :forms]
  before_filter :required_attributes, only: [:create]
  before_filter :authorized_create_post, only: [:create]
  before_filter :ensure_post_attributes, only: [:create]
  before_filter :authorized_read_post, only: [:get_comments, :create_comments]
  def unread_receipts
    access_denied! unless can?(current_user, :manage, @post)
    unread_receipts = @post.receipts.unread
    render json: unread_receipts, each_serializer: ReceiptAdminSerializer, root: :unread_receipts
  end

  def get_comments
    comments = @post.comments
    render json: comments, each_serializer: CommentSerializer, root: :comments
  end
  def create_comments
    params[:comment][:user_id] = current_user.id
    comment = @post.comments.new(params[:comment])
    if comment.save
      render json: comment, status: :created
    else
      render json: comment.errors, status: :unprocessable_entity
    end
  end

  def forms
    access_denied! unless can?(current_user, :read, @post)
    forms = @post.forms
    render json: forms, each_serializer: FormSerializer, root: :forms
  end

  def create
    if @post.save
      @attachments.map { |attachment| @post.attachments << attachment }
      @forms.map { |form| @post.forms << form }
      @post.sms_schedulers.create delayed_at: @delayed_at if @delayed_at
      render json: @post, status: :created
    else
      fail!(@post.errors)
    end

  end

  private
  def ensure_post
    @post = Post.find(params[:id])
  end

  def required_attributes
    required_attributes! [:body_html, :organization_ids]
  end
  def authorized_create_post
    bulk_authorize! :create_youxin, Organization.where(:id.in => params[:organization_ids])
  end
  def ensure_post_attributes
    attrs = attributes_for_keys [:title, :body_html, :organization_ids, :attachment_ids, :delayed_sms_at, :form_ids]
    attachment_ids = attrs.delete(:attachment_ids)
    @delayed_at = Time.at(attrs.delete(:delayed_sms_at).to_i) if attrs[:delayed_sms_at].present?
    form_ids = attrs.delete(:form_ids)
    @post = current_user.posts.new attrs

    @forms = []
    form_ids.each do |form_id|
      form = Form.find(form_id)
      not_found!("form") unless form
      authorize! :manage, form

      if form.post_id.present?
        @post.errors.add :form_ids, :inclusion
      end
      @forms |= [form]
    end if form_ids

    @attachments = []
    attachment_ids.each do |attachment_id|
      attachment = Attachment::Base.find(attachment_id)

      not_found!("attachment") unless attachment
      authorize! :manage, attachment

      if attachment.post_id.present?
        @post.errors.add :attachment_ids, :inclusion
      end
      @attachments |= [attachment]
    end if attachment_ids    
  end
  def authorized_read_post
    return access_denied! unless can?(current_user, :read, @post)
  end
end