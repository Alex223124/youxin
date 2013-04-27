require 'spec_helper'

describe GridfsController do
  it "to #serve" do
    get('/uploads/avatar/test.png').should route_to(controller: 'gridfs', action: 'serve', path: 'test', format: 'png')
    get('/uploads/avatar').should_not be_routable
    post('/uploads/avatar/test.png').should_not be_routable
  end
end