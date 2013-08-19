require 'spec_helper'

describe CollectionsController do
  it "to #create" do
    post('/forms/123/collections').should route_to('collections#create', form_id: '123')
  end
  it "to #index" do
    get('/forms/123/collections').should route_to('collections#index', form_id: '123')
  end
  it "to #show" do
    get('/forms/123/collection').should route_to('collections#show', form_id: '123')
  end
end
