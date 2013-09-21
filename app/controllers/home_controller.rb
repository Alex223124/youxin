class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:features, :privacy, :terms]

  def index
  end
  def features
  end
  def privacy
  end
  def terms
  end
end
