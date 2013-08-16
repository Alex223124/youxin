require 'spec_helper'

describe ReceiptsController do
  it "to #index" do
    get('/receipts').should route_to('receipts#index')
  end
  it "to #read" do
    put('/receipts/123/read').should route_to('receipts#read', id: '123')
  end
  it "to #favorite" do
    post('/receipts/123/favorite').should route_to('receipts#favorite', id: '123')
  end
  it "to #read" do
    delete('/receipts/123/favorite').should route_to('receipts#unfavorite', id: '123')
  end
end
