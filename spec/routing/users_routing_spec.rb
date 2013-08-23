require 'spec_helper'

describe UsersController do
  it "to #organizations" do
    get('/users/123/organizations').should route_to('users#organizations', id: '123')
  end
  it "to #authorized_organizations" do
    get('/users/123/authorized_organizations').should route_to('users#authorized_organizations', id: '123')
  end
  it "to #update" do
    put('/users/123').should route_to('users#update', id: '123')
  end
  it "to #show" do
    get('/users/123').should route_to('users#show', id: '123')
  end
  it "to #receipts" do
    get('/users/123/receipts').should route_to('users#receipts', id: '123')
  end
end
