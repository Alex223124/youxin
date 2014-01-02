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
  it "to #archive" do
    put('/receipts/123/archived').should route_to('receipts#archive', id: '123')
  end
  it "to #unarchive" do
    delete('/receipts/123/archived').should route_to('receipts#unarchive', id: '123')
  end
  it "to #mobile_show" do
    get('/r/123').should route_to('receipts#mobile_show', short_key: '123')
  end
  it "to #mobile_collection_create" do
    post('/r/123/c').should route_to('receipts#mobile_collection_create', short_key: '123')
  end
end
