require 'spec_helper'

describe Admin::UsersController do
  it "to #index" do
    get('/admin/users').should route_to('admin/users#index')
  end

  it "to #new" do
    get('/admin/users/new').should route_to('admin/users#new')
  end
end

describe Admin::MembersController do
  it "to #idnex" do
    get('/admin/organizations/1/members').should route_to('admin/members#index', id: '1')
  end

  it "to #update" do
    put('/admin/organizations/1/members').should route_to('admin/members#update', id: '1')
  end

  it "to #destroy" do
    delete('/admin/organizations/1/members').should route_to('admin/members#destroy', id: '1')
  end
end