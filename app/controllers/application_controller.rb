# encoding: utf-8

require_dependency 'youxin'
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :add_abilities

  helper_method :abilities, :can?

  rescue_from Youxin::Forbidden do |exception|
    log_exception(exception)
    render json: '没有相应的权限', status: :forbidden
  end

  rescue_from Youxin::NotFound do |exception|
    log_exception(exception)
    render json: "#{exception.message || 资源} 未找到", status: :not_found
  end

  rescue_from Youxin::InvalidParameters do |exception|
    log_exception(exception)
    render json: "参数 #{exception.message} 不存在", status: :bad_request
  end

  protected
  def paginate(objects)
    per_page = (params[:per_page] || Kaminari.config.default_per_page).to_i
    page = (params[:page] || 1).to_i
    since_id = params[:since_id]
    max_id = params[:max_id]
    objects = objects.gt(_id: since_id) if since_id
    objects = objects.lt(_id: max_id) if max_id
    objects.page(page).per(per_page)
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


# ------------need fix-------------
  def authenticated_as_attachmentable
    if current_user.authorized_organizations([:create_youxin]).blank?
      return access_denied!
    end
  end


  def attributes_for_keys(keys)
    attrs = {}
    keys.each do |key|
      attrs[key] = params[key] if params[key].present?
    end
    attrs
  end

  def bad_request!
    render 'public/400', status: 400
  end

  def not_found!
    render 'public/404', status: 404
  end

  def access_denied!
    render "public/403", status: 403
  end

  def fail!(errors = nil)
    if errors
      messages = errors.messages
    else
      messages = { message: 'failure' }
    end
    render json: messages, status: :unprocessable_entity
  end

  # def authorize! action, subject
  #   unless abilities.allowed?(current_user, action, subject)
  #     return false
  #   end
  #   true
  # end
  # def bulk_authorize! action, subjects
  #   subjects.each do |subject|
  #     return false unless authorize!(action, subject)
  #   end
  #   true
  # end


end
