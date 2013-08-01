class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :add_abilities

  helper_method :abilities, :can?

  protected
  def abilities
    @abilities ||= Six.new
  end
  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end
  def add_abilities
    abilities << UserActionsOrganizationRelationship
    abilities << Post
    abilities << Attachment::Base
    abilities << Conversation
    abilities
  end

  def authenticated_as_attachmentable
    if current_user.authorized_organizations([:create_youxin]).blank?
      return access_denied!
    end
  end

  def required_attributes!(keys)
    keys.each do |key|
      bad_request! and return unless params[key].present?
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

  def authorize! action, subject
    unless abilities.allowed?(current_user, action, subject)
      return false
    end
    true
  end
  def bulk_authorize! action, subjects
    subjects.each do |subject|
      return false unless authorize!(action, subject)
    end
    true
  end


end
