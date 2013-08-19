require 'spec_helper'

describe MembersController do
  it "to #index" do
    get('/organizations/123/members').should route_to('members#index', organization_id: '123')
  end
  it "to #create" do
    post('/organizations/123/members').should route_to('members#create', organization_id: '123')
  end
  it "to #import" do
    post('/organizations/123/members/import').should route_to('members#import', organization_id: '123')
  end
  it "to #update" do
    put('/organizations/123/members').should route_to('members#update', organization_id: '123')
  end
  it "to #destroy" do
    delete('/organizations/123/members').should route_to('members#destroy', organization_id: '123')
  end
  it "to #update_role" do
    put('/organizations/123/members/role').should route_to('members#update_role', organization_id: '123')
  end
  it "to #destroy_role" do
    delete('/organizations/123/members/role').should route_to('members#destroy_role', organization_id: '123')
  end
end
