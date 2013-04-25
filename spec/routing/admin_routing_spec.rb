require 'spec_helper'

describe Admin::UsersController do
  it "to #index" do
    get('/admin/users').should route_to('admin/users#index')
  end

  it "to #new" do
    get('/admin/users/new').should route_to('admin/users#new')
  end
end