require 'spec_helper'

describe OrganizationsController do
  it "to #index" do
    get('/organizations').should route_to('organizations#index')
  end
  it "to #create" do
    post('/organizations/123/children').should route_to('organizations#create_children', id: '123')
  end
  it "to #update" do
    put('/organizations/123').should route_to('organizations#update', id: '123')
  end
end
