class Lite::SessionsController < Devise::SessionsController
  include Lite::ApplicationHelper

  layout 'lite'

  protected
  def after_sign_in_path_for(resource)
    lite_root_path
  end

end
