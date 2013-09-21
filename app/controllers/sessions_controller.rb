class SessionsController < Devise::SessionsController
  before_filter :ensure_resource!, only: [:create], if: :subdomain_request?

  protected
  def ensure_resource!
    login = params[:user][:login] rescue nil
    unless login and current_namespace.users.find_for_database_authentication(login: login)
      flash[:alert] = I18n.t("devise.failure.not_found_in_database")
      redirect_to :back and return
    end
  end
end
