class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    unless signed_in?
      if is_mobile_device?
        redirect_to app_path
      else
        redirect_to introduction_path
      end
    end
  end
  def privacy
    render layout: 'features'
  end
  def terms
    render layout: 'features'
  end

  def app
    render layout: 'app'
  end
  def welcome
    render layout: 'features'
  end

  def introduction
    render layout: 'features'
  end
end
