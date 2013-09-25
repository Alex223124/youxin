class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:features, :privacy, :terms]

  def index
  end
  def privacy
    render layout: 'features'
  end
  def terms
    render layout: 'features'
  end
end
