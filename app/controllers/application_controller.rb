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
    abilities
  end

  def access_denied!
    render "public/404", status: 404
  end

end
