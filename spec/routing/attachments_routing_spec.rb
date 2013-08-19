require 'spec_helper'

describe AttachmentsController do
  it "to #show" do
    get('/attachments/123').should route_to('attachments#show', id: '123')
  end
  it "to #create" do
    post('/attachments').should route_to('attachments#create')
  end
  it "to #index" do
    get('/posts/123/attachments').should route_to('attachments#index', post_id: '123')
  end
end
