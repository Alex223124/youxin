require 'spec_helper'

describe Admin::NamespacesController, 'routing' do
  it 'to #index' do
    get('/admin/namespaces').should route_to('admin/namespaces#index')
  end
  it 'to #show' do
    get('/admin/namespaces/1').should route_to('admin/namespaces#show', id: '1')
  end
end

describe Admin::UsersController, 'routing' do
  it 'to #show' do
    get('/admin/namespaces/1/users/1').should route_to('admin/users#show', namespace_id: '1', id: '1')
  end
end
