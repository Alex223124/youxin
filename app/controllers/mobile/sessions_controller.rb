class Mobile::SessionsController < Devise::SessionsController
  include Mobile::ApplicationHelper

  layout 'mobile'

  protected
  def after_sign_in_path_for(resource)
    mobile_root_path
  end

end
