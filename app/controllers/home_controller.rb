class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    if is_mobile_device? && request.subdomain != 'm'
      redirect_to lite_root_url(subdomain: :m)
    else
      unless current_user
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
