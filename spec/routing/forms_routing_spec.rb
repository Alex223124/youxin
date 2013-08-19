require 'spec_helper'

describe FormsController do
  it "to #create" do
    post('/forms').should route_to('forms#create')
  end
  it "to #download" do
    get('/forms/123/download').should route_to('forms#download', id: '123')
  end
end
