require 'spec_helper'

describe HomeController do
  it "to #index" do
    get('/').should route_to('home#index')
  end
  it "to #index" do
    get('/privacy').should route_to('home#privacy')
  end
  it "to #index" do
    get('/terms').should route_to('home#terms')
  end
end
