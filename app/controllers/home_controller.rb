class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    redirect_to introduction_path unless signed_in?
  end
  def privacy
    render layout: 'features'
  end
  def terms
    render layout: 'features'
  end

  def app
    render layout: 'mobile'
  end
  def welcome
    render layout: 'features'
  end

  def introduction
    render layout: 'features'
  end
end
