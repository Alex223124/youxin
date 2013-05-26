module Youxin
  module APIHelpers
    def current_user
      @current_user ||= User.where(authentication_token: params[:private_token] || env["HTTP_PRIVATE_TOKEN"]).first
    end

    def authenticate!
      unauthorized! unless current_user
    end
    def authorize! action, subject
      unless abilities.allowed?(current_user, action, subject)
        forbidden!
      end
    end
    def bulk_authorize! action, subjects
      subjects.each do |subject|
        authorize!(action, subject)
      end
    end
    def authenticated_as_attachmentable
      if current_user.authorized_organizations([:create_youxin]).blank?
        forbidden!
      end
    end

    # Checks the occurrences of required attributes, each attribute must be present in the params hash
    # or a Bad Request error is invoked.
    #
    # Parameters:
    #   keys (required) - A hash consisting of keys that must be present
    def required_attributes!(keys)
      keys.each do |key|
        bad_request!(key) unless params[key].present?
      end
    end

    def attributes_for_keys(keys)
      attrs = {}
      keys.each do |key|
        attrs[key] = params[key] if params[key].present?
      end
      attrs
    end

    # errors
    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end
    def render_api_error!(message, status)
      error!({'message' => message}, status)
    end
    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end
    def bad_request!(attribute)
      message = ["400 (Bad request)"]
      message << "\"" + attribute.to_s + "\" not given"
      render_api_error!(message.join(' '), 400)
    end
    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end
    def fail!(errors = nil)
      if errors
        messages = errors.messages
      else
        messages = { message: 'failure' }
      end
      error!(messages, 400)
    end

    private

    def abilities
      @abilities ||= begin
                       abilities = Six.new
                       abilities << UserActionsOrganizationRelationship
                       abilities
                     end
    end
  end
end