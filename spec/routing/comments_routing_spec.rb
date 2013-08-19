require 'spec_helper'

describe CommentsController do
  it "to #index" do
    get('/posts/123/comments').should route_to('comments#index', post_id: '123')
  end
  it "to #create" do
    post('/posts/123/comments').should route_to('comments#create', post_id: '123')
  end
end
