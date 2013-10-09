# encoding: utf-8

require_dependency 'youxin'
class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery

  before_filter :ensure_namespace!, if: :subdomain_request?
  before_filter :authenticate_user!
  before_filter :add_abilities

  helper_method :abilities, :can?, :current_namespace

  rescue_from Youxin::Forbidden do |exception|
    log_exception(exception)
    render json: '没有相应的权限', status: :forbidden
  end

  rescue_from Youxin::NotFound do |exception|
    log_exception(exception)
    render json: "#{exception.message || 资源}未找到", status: :not_found
  end

  rescue_from Youxin::InvalidParameters do |exception|
    log_exception(exception)
    render json: "参数 #{exception.message} 有问题", status: :bad_request
  end

  protected
  def paginate(objects)
    objects = range(objects)
    per_page = (params[:per_page] || Kaminari.config.default_per_page).to_i
    page = (params[:page] || 1).to_i
    objects.page(page).per(per_page)
  end
  def range(objects)
    since_id = params[:since_id]
    max_id = params[:max_id]
    objects = objects.gt(_id: since_id) if since_id
    objects = objects.lt(_id: max_id) if max_id
    objects
  end

  def log_exception(exception)
    application_trace = ActionDispatch::ExceptionWrapper.new(env, exception).application_trace
    application_trace.map!{ |t| "  #{t}\n" }
    logger.error "\n#{exception.class.name} (#{exception.message}):\n#{application_trace.join}"
  end

  # Authorization
  def abilities
    @abilities ||= Six.new
  end
  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end
  def current_user_can?(action, subject)
    abilities.allowed?(current_user, action, subject)
  end
  def add_abilities
    abilities << UserActionsOrganizationRelationship
    abilities << Post
    abilities << Attachment::Base
    abilities << Conversation
    abilities << Form
    abilities
  end

  def method_missing(method_sym, *arguments, &block)
    if method_sym.to_s =~ /^authorize_(.*)!$/
      authorize!($1.to_sym, @organization)
    else
      super(method_sym, *arguments, &block)
    end
  end

  def authorize!(action, subject)
    raise Youxin::Forbidden unless current_user_can?(action, subject)
  end

  def required_attributes!(keys)
    keys.each do |key|
      raise Youxin::InvalidParameters.new(key) unless params.has_key?(key)
    end
  end

  def bulk_authorize! action, subjects
    subjects.each { |subject| authorize!(action, subject) }
  end

  def ensure_namespace!
    unless current_namespace and current_namespace.subdomain_enabled?
      sign_out current_user
      redirect_to main_url and return
    end
  end

  private

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

end
