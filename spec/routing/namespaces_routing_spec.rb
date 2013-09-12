require 'spec_helper'

describe NamespacesController do
  it "to #show" do
    get('/namespace').should route_to('namespaces#show')
  end
  it "to #update" do
    put('/namespace').should route_to('namespaces#update')
  end
end
