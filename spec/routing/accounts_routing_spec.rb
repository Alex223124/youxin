require 'spec_helper'

describe AccountsController do
  it "to #notifications_counter" do
    get('/account/notifications_counter').should route_to('accounts#notifications_counter')
  end
  it "to #organizations" do
    get('/account/organizations').should route_to('accounts#organizations')
  end
  it "to #authorized_organizations" do
    get('/account/authorized_organizations').should route_to('accounts#authorized_organizations')
  end
  it "to #recent_authorized_organizations" do
    get('/account/recent_authorized_organizations').should route_to('accounts#recent_authorized_organizations')
  end
  it "to #update" do
    put('/account').should route_to('accounts#update')
  end
  it "to #show" do
    get('/account').should route_to('accounts#show')
  end
  it "to #created_receipts" do
    get('/account/created_receipts').should route_to('accounts#created_receipts')
  end
  it "to #favorited_receipts" do
    get('/account/favorited_receipts').should route_to('accounts#favorited_receipts')
  end
end
