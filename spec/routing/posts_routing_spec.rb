require 'spec_helper'

describe PostsController do
  it "to #unread_receipts" do
    get('/posts/123/unread_receipts').should route_to('posts#unread_receipts', id: '123')
  end
  it "to #forms" do
    get('/posts/123/forms').should route_to('posts#forms', id: '123')
  end
  it "to #create" do
    post('/posts').should route_to('posts#create')
  end
  it "to #run_sms_notifications_now" do
    post('/posts/123/run_sms_notifications_now').should route_to('posts#run_sms_notifications_now', id: '123')
  end
  it "to #last_sms_scheduler" do
    get('/posts/123/last_sms_scheduler').should route_to('posts#last_sms_scheduler', id: '123')
  end
  it "to #run_call_notifications_now" do
    post('/posts/123/run_call_notifications_now').should route_to('posts#run_call_notifications_now', id: '123')
  end
  it "to #last_call_scheduler" do
    get('/posts/123/last_call_scheduler').should route_to('posts#last_call_scheduler', id: '123')
  end
end
