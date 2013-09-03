# encoding: utf-8

class PostsController < ApplicationController
  before_filter :ensure_post!, only: [:unread_receipts, :forms, :run_sms_notifications_now, :last_sms_scheduler, :run_call_notifications_now, :last_call_scheduler]
  before_filter :authorized_manage_post!, only: [:unread_receipts, :run_sms_notifications_now, :last_sms_scheduler, :run_call_notifications_now, :last_call_scheduler]
  before_filter :authorized_read_post!, only: [:forms]

  before_filter :prepare_post_params, only: [:create]
  before_filter :authorized_create_post!, only: [:create]
  before_filter :authorized_manage_additions!, only: [:create]

  before_filter :authorized_read_post, only: [:get_comments, :create_comments]
  def unread_receipts
    unread_receipts = @post.receipts.unread
    render json: unread_receipts, each_serializer: ReceiptAdminSerializer, root: :unread_receipts
  end

  def forms
    forms = @post.forms
    render json: forms, each_serializer: FormSerializer, root: :forms
  end

  def create
    post = current_user.posts.new params[:post]
    if post.save
      @attachments.each { |attachment| post.attachments << attachment }
      @forms.each { |form| post.forms << form }
      post.sms_schedulers.create delayed_at: Time.at(@delayed_sms_at.to_i) if @delayed_sms_at
      render json: post, status: :created
    else
      render json: post.errors, status: :unprocessable_entity
    end
  end

  def run_sms_notifications_now
    scheduler = @post.sms_schedulers.where(ran_at: nil).first
    if scheduler
      scheduler.run_now!
    else
      @post.sms_schedulers.create delayed_at: Time.now
    end
    head :no_content
  end

  def last_sms_scheduler
    last_sms_scheduler = @post.sms_schedulers.where(ran_at: nil).first || @post.sms_schedulers.first
    render json: last_sms_scheduler, serializer: SchedulerSerializer, root: :sms_scheduler
  end

  def run_call_notifications_now
    scheduler = @post.call_schedulers.where(ran_at: nil).first
    if scheduler
      scheduler.run_now!
    else
      @post.call_schedulers.create delayed_at: Time.now
    end
    head :no_content
  end

  def last_call_scheduler
    last_call_scheduler = @post.call_schedulers.where(ran_at: nil).first || @post.call_schedulers.first
    render json: last_call_scheduler, serializer: SchedulerSerializer, root: :call_scheduler
  end

  private
  def ensure_post!
    @post = Post.where(id: params[:id]).first
    raise Youxin::NotFound unless @post
  end
  def authorized_manage_post!
    raise Youxin::Forbidden unless current_user_can?(:manage, @post)
  end
  def authorized_read_post!
    raise Youxin::Forbidden unless current_user_can?(:read, @post)
  end
  def prepare_post_params
    @organization_ids = params[:post][:organization_ids]
    @attachment_ids = params[:post].delete(:attachment_ids)
    @form_ids = params[:post].delete(:form_ids)
    @delayed_sms_at = params[:post].delete(:delayed_sms_at)

    params[:post]
  end
  def authorized_create_post!
    if @organization_ids
      bulk_authorize! :create_youxin, current_namespace.organizations.where(:id.in => @organization_ids)
    else
      raise Youxin::NotFound.new('组织')
    end
  end
  def authorized_manage_additions!
    @forms = []
    @form_ids.each do |form_id|
      form = Form.where(id: form_id, post_id: nil).first
      raise Youxin::NotFound.new('表格') unless form
      authorize! :manage, form

      @forms |= [form]
    end if @form_ids

    @attachments = []
    @attachment_ids.each do |attachment_id|
      attachment = Attachment::Base.where(id: attachment_id, post_id: nil).first
      raise Youxin::NotFound.new('附件') unless attachment
      authorize! :manage, attachment

      @attachments |= [attachment]
    end if @attachment_ids
  end
end